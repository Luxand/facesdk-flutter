import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' show max, min;
import 'dart:typed_data';

import 'package:camera/camera.dart' show CameraImage;
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_face_sdk/converter.dart' show ImageConverter, ImageInfo;
import 'package:flutter_face_sdk/flutter_face_sdk.dart' as FSDK;
import 'package:path_provider/path_provider.dart';


const _maxTrackedFaces = 5;

// Below this image quality the iBeta liveness score is not trustworthy
const _livenessQualityThreshold = 0.5;

// Liveness scores above this mean a live face
const _livenessThreshold = 0.5;

// The face crop is scaled to this width before the sharpness is measured,
// so the metric does not depend on how close the face is to the camera
const _sharpnessCropWidth = 128;

// Faces blurrier than this get no liveness verdict. Picked from the measured
// distributions: live faces sit around 570, blurred ones around 130
const sharpnessThreshold = 125.0;


// Liveness verdict for a tracked face.
// "unknown", "lowQuality" and "blurred" mean no liveness decision was made.
enum LivenessStatus {
  unknown, lowQuality, blurred, live, fake
}

class FacePoint {

  final double x;
  final double y;

  const FacePoint(this.x, this.y);

}

class FaceSnapshot {

  final int id;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String name;
  final LivenessStatus livenessStatus;
  // Liveness score, null when the Liveness attribute is not available yet
  final double? liveness;
  // Image quality score, null when the ImageQuality attribute is not available
  final double? quality;
  // Variance of the Laplacian over the face crop, null when it cannot be
  // measured. The SDK image quality does not react to motion blur, this does
  final double? sharpness;
  final String livenessError;
  final List<FacePoint> features;

  const FaceSnapshot(this.id, this.left, this.top, this.right, this.bottom, this.name, this.livenessStatus, this.liveness, this.quality, this.sharpness, this.livenessError, this.features);

}

class FaceMatchResult {

  final String name;
  final int id;
  final double similarity;

  FaceMatchResult(this.name, this.id, this.similarity);

}


class _WorkerConfig {

  final SendPort port;
  final int trackerHandle;

  _WorkerConfig(this.port, this.trackerHandle);

}

class _FrameRequest {

  final List<Uint8List> planes;
  final ImageInfo info;
  final int orientation;
  final bool frontFacing;

  _FrameRequest(this.planes, this.info, this.orientation, this.frontFacing);

}

class _FrameResult {

  final List<FaceSnapshot> faces;
  final int width;
  final int height;

  _FrameResult(this.faces, this.width, this.height);

}

class _StopRequest {

  const _StopRequest();

}

class _ResetRequest {

  const _ResetRequest();

}


void _setTrackerParameters(FSDK.Tracker tracker) {
  tracker.setMultipleParameters({
    'FaceDetectionPatchSize': 128,
  });

  // Setting parameters for iBeta liveness plugin
  tracker.setMultipleParameters({
    'DetectLiveness': true,
    'SmoothAttributeLiveness': false,
    'LivenessFramesCount': 1
  });
}


void _workerEntry(_WorkerConfig config) {
  final tracker = FSDK.Tracker.fromHandle(config.trackerHandle);
  final converter = ImageConverter();
  final ids = FSDK.Int64Buffer.allocate(_maxTrackedFaces);
  final receive = ReceivePort();

  receive.listen((message) {
    if (message is _StopRequest) {
      converter.free();
      ids.free();
      receive.close();
      return;
    }

    // Clearing the tracker on the isolate that feeds it keeps FSDK_ClearTracker
    // from running while FSDK_FeedFrame is in flight on this isolate.
    if (message is _ResetRequest) {
      tracker.clear();
      _setTrackerParameters(tracker);
      return;
    }

    if (message is _FrameRequest) {
      config.port.send(_handleFrame(tracker, converter, ids, message));
    }
  });

  config.port.send(receive.sendPort);
}

_FrameResult _handleFrame(FSDK.Tracker tracker, ImageConverter converter, FSDK.Int64Buffer ids, _FrameRequest request) {
  var image = converter.convertPlanes(request.planes, request.info);

  final rotation = Platform.isAndroid ? request.orientation ~/ 90 : -(request.orientation ~/ 90) + 1;

  if (rotation != 0) {
    final rotated = image.rotate90(rotation);
    image.free();
    image = rotated;
  }

  if (request.frontFacing && !Platform.isIOS) {
    image.mirror(true);
  }

  ids.length = 0;

  try {
    tracker.feedFrame(0, image, ids: ids);
  } on FSDK.FaceNotFoundError {
    /*No faces were found*/
  }

  final faces = <FaceSnapshot>[];

  // The frame is still alive here, so the sharpness of every face is measured
  // on the very frame the tracker has just processed
  for (final id in ids) {
    final snapshot = _snapshot(tracker, image, id);
    if (snapshot != null) {
      faces.add(snapshot);
    }
  }

  image.free();

  return _FrameResult(faces, request.info.width, request.info.height);
}

FaceSnapshot? _snapshot(FSDK.Tracker tracker, FSDK.Image frame, int id) {
  try {
    final face = tracker.getFace(0, id);

    tracker.lockID(id);
    final name = tracker.getAllNames(id);
    tracker.unlockID(id);

    final liveness = _liveness(tracker, frame, face, id);

    return FaceSnapshot(
      id,
      face.leftAsDouble,
      face.topAsDouble,
      face.rightAsDouble,
      face.bottomAsDouble,
      name,
      liveness.status,
      liveness.value,
      liveness.quality,
      liveness.sharpness,
      liveness.error,
      face.features.map((point) => FacePoint(point.x.toDouble(), point.y.toDouble())).toList(growable: false)
    );
  } on FSDK.IdNotFoundError {
    return null;
  }
}

class _Liveness {

  final LivenessStatus status;
  final double? value;
  final double? quality;
  final double? sharpness;
  final String error;

  const _Liveness(this.status, {this.value, this.quality, this.sharpness, this.error = ''});

}

// Determines the liveness status the same way the Android sample does:
// a face with a low image quality or a blurred face gets no liveness verdict
_Liveness _liveness(FSDK.Tracker tracker, FSDK.Image frame, FSDK.Face face, int id) {
  final double value;

  try {
    value = FSDK.GetValueConfidence(tracker.getFacialAttribute(0, id, 'Liveness'), 'Liveness');
  } on FSDK.AttributeNotDetectedError {
    // Liveness was not determined for this face yet
    return const _Liveness(LivenessStatus.unknown);
  }

  double? quality;

  try {
    quality = FSDK.GetValueConfidence(tracker.getFacialAttribute(0, id, 'ImageQuality'), 'ImageQuality');
  } on FSDK.AttributeNotDetectedError {
    /*No image quality to report*/
  }

  if (quality != null && quality < _livenessQualityThreshold) {
    return _Liveness(LivenessStatus.lowQuality, value: value, quality: quality, error: 'Image quality is too low');
  }

  // The liveness score drops on motion blur that the SDK image quality
  // does not react to, so a blurred face gets no verdict either
  final sharpness = _sharpness(frame, face);

  if (sharpness != null && sharpness < sharpnessThreshold) {
    return _Liveness(LivenessStatus.blurred, value: value, quality: quality, sharpness: sharpness, error: 'Face is too blurred');
  }

  if (value > _livenessThreshold) {
    return _Liveness(LivenessStatus.live, value: value, quality: quality, sharpness: sharpness);
  }

  var error = '';

  try {
    error = _parseLivenessErrorMessage(tracker.getFacialAttribute(0, id, 'LivenessError'));
  } on FSDK.AttributeNotDetectedError {
    /*No liveness error to report*/
  }

  return _Liveness(LivenessStatus.fake, value: value, quality: quality, sharpness: sharpness, error: error);
}

// Extracts the message from a "LivenessError=<message>;" attribute value.
// Falls back to the raw string if it does not have the expected shape.
String _parseLivenessErrorMessage(String attribute) {
  const key = 'LivenessError=';

  var message = attribute.startsWith(key) ? attribute.substring(key.length) : attribute;

  if (message.endsWith(';')) {
    message = message.substring(0, message.length - 1);
  }

  return message;
}

// Variance of the Laplacian over the face crop: the classic sharpness
// metric. Low values mean a blurred face, high values a sharp one.
// The crop is a square of the face width around the face center, scaled
// to a fixed width to keep the values comparable
double? _sharpness(FSDK.Image frame, FSDK.Face face) {
  final size = face.width;
  if (size <= 0) {
    return null;
  }

  final xc = (face.left + face.right) ~/ 2;
  final yc = (face.top + face.bottom) ~/ 2;
  final half = size ~/ 2;

  final x1 = max(xc - half, 0);
  final y1 = max(yc - half, 0);
  final x2 = min(xc + half, frame.width);
  final y2 = min(yc + half, frame.height);

  if (x2 - x1 < 8 || y2 - y1 < 8) {
    return null;
  }

  FSDK.Image? crop;
  FSDK.Image? scaled;
  FSDK.DataBuffer? buffer;

  try {
    crop = frame.copyRect(x1, y1, x2, y2);

    final ratio = _sharpnessCropWidth / (x2 - x1);
    scaled = ratio < 1 ? crop.resize(ratio) : null;

    final image = scaled ?? crop;
    final width = image.width;
    final height = image.height;

    if (width < 3 || height < 3) {
      return null;
    }

    buffer = image.saveToBuffer(FSDK.ImageMode.Grayscale8bit);

    // Laplacian of every interior pixel, accumulated for mean and variance
    double sum = 0;
    double sumOfSquares = 0;
    int count = 0;

    for (int y = 1; y < height - 1; ++y) {
      final row = y * width;

      for (int x = 1; x < width - 1; ++x) {
        final laplacian = 4 * buffer[row + x]
                            - buffer[row + x - 1]
                            - buffer[row + x + 1]
                            - buffer[row - width + x]
                            - buffer[row + width + x];

        sum += laplacian;
        sumOfSquares += laplacian * laplacian;
        ++count;
      }
    }

    if (count == 0) {
      return null;
    }

    final mean = sum / count;
    return sumOfSquares / count - mean * mean;
  } on FSDK.Error {
    return null;
  } finally {
    buffer?.free();
    scaled?.free();
    crop?.free();
  }
}


class FacesTracker extends ChangeNotifier {

  static const _path = 'tracker.bin';

  final _tracker = FSDK.Tracker();
  final _receive = ReceivePort();
  final _errors = ReceivePort();
  final _exits = ReceivePort();

  String _trackerPath = '';

  bool _disposed = false;
  bool _initializing = false;
  bool _busy = false;

  Isolate? _isolate;
  SendPort? _send;

  Object? _failure;
  List<FaceSnapshot> _faces = const <FaceSnapshot>[];
  int _width = 0;
  int _height = 0;

  FacesTracker();

  int get width => _width;
  int get height => _height;

  Object? get failure => _failure;
  List<FaceSnapshot> get faces => _faces;

  void saveTracker() {
    if (_trackerPath.isEmpty) {
      return;
    }

    _tracker.saveToFile(_trackerPath);
  }

  @override
  void dispose() {
    _disposed = true;

    final send = _send;
    if (send != null) {
      send.send(const _StopRequest());
    } else {
      _isolate?.kill(priority: Isolate.immediate);
    }

    _isolate = null;
    _send = null;

    _receive.close();
    _errors.close();
    _exits.close();

    saveTracker();
    _tracker.free();

    super.dispose();
  }

  Future<void> _openTracker() async {
    final directory = await getApplicationDocumentsDirectory();
    _trackerPath = '${directory.path}/$_path';

    try {
      FSDK.Tracker.fromFile(_trackerPath, tracker: _tracker);
    } on FSDK.Error {
      // Couldn't load tracker from memory, file may not exist
    }

    _setTrackerParameters(_tracker);
  }

  Future<void> _initialize() async {
    try {
      await _openTracker();

      if (_disposed) {
        return;
      }

      _receive.listen(_onMessage);
      _errors.listen(_onError);
      _exits.listen(_onExit);

      _isolate = await Isolate.spawn(
        _workerEntry,
        _WorkerConfig(_receive.sendPort, _tracker.handle),
        onError: _errors.sendPort,
        onExit: _exits.sendPort
      );
    } catch (error) {
      _fail(error);
    } finally {
      _initializing = false;
    }
  }

  void _onMessage(dynamic message) {
    if (message is SendPort) {
      _send = message;
      return;
    }

    if (message is! _FrameResult) {
      return;
    }

    _faces = message.faces;
    _width = message.width;
    _height = message.height;
    _busy = false;

    notifyListeners();
  }

  void _onError(dynamic message) {
    _fail(message is List && message.isNotEmpty ? message.first ?? 'Worker failed' : 'Worker failed');
  }

  void _onExit(dynamic message) {
    if (_disposed || _failure != null) {
      return;
    }

    _fail('Worker isolate exited unexpectedly');
  }

  void _fail(Object error) {
    if (_disposed) {
      return;
    }

    _failure = error;
    _busy = false;
    _faces = const <FaceSnapshot>[];

    notifyListeners();
  }

  void process(CameraImage image, int orientation, bool frontFacing) {
    if (_disposed || _failure != null) {
      return;
    }

    if (_isolate == null) {
      if (!_initializing) {
        _initializing = true;
        unawaited(_initialize());
      }

      return;
    }

    final send = _send;
    if (send == null || _busy) {
      return;
    }

    _busy = true;

    send.send(_FrameRequest(
      image.planes.map((plane) => plane.bytes).toList(growable: false),
      ImageInfo.forImage(image),
      orientation,
      frontFacing
    ));
  }

  void resetTracker() {
    final send = _send;
    if (send == null) {
      _tracker.clear();
      _setTrackerParameters(_tracker);
      return;
    }

    send.send(const _ResetRequest());
  }

  void setNameForId(int id, String name) {
    _tracker.lockID(id);
    _tracker.setName(id, name);
    _tracker.unlockID(id);
  }

  String getNameForId(int id) {
    _tracker.lockID(id);
    final name = _tracker.getName(id);
    _tracker.unlockID(id);

    return name;
  }

  FaceMatchResult matchFace(FSDK.Image img) {
    final faceTemplate = FSDK.GetFaceTemplate(img);
    final similarityResults = _tracker.matchFaces(faceTemplate, 0.65);

    if (similarityResults.isNotEmpty) {
      final id = similarityResults[0].id;
      final similarity = similarityResults[0].similarity;

      return FaceMatchResult(getNameForId(id), id, similarity);
    }

    return FaceMatchResult("", -1, 0.0);
  }

}
