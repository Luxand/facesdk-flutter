import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_face_sdk/converter.dart' show ImageConverter;
import 'package:flutter_face_sdk/flutter_face_sdk.dart' as FSDK;
import 'package:flutter_face_sdk/flutter_face_sdk.dart' show BufferInfo, Error, FacePosition, Face, FaceNotFoundError, FacialFeatures, Image, Int64Buffer, Tracker, GetValueConfidence;
import 'package:path_provider/path_provider.dart';


class _FacesTrackerIsolateInfo {

  final SendPort port;
  final int trackerHandle;
  final BufferInfo idsBufferInfo;

  _FacesTrackerIsolateInfo(this.port, this.trackerHandle, this.idsBufferInfo);

}


class _WorkerData {

  final int image;
  final int orientation;
  final bool frontFacing;

  _WorkerData(this.image, this.orientation, this.frontFacing);
}

class FaceWrapper {

  final int _id;
  final Tracker _tracker;

  String? _name;
  FacePosition? _position;
  FacialFeatures? _features;
  Face? _face;

  double? _liveness;
  String? _livenessError;

  FaceWrapper(this._id, this._tracker);

  int get id => _id;

  String get name {
    if (_name == null) {  
      _tracker.lockID(_id);
      _name = _tracker.getAllNames(_id);
      _tracker.unlockID(_id);
    }

    return _name!;
  }

  FacePosition get position {
    _position ??= _tracker.getFacePosition(0, _id);
    return _position!;
  }

  FacialFeatures get features {
    _features ??= _tracker.getFacialFeatures(0, _id);
    return _features!;
  }

  Face get face {
    _face = _tracker.getFace(0, _id);
    return _face!;
  }

  String get livenessError {
    return _livenessError!;
  }

  double get liveness {
    return _liveness!;
  }

  bool checkLiveness() {
    _livenessError = "";
    try {
      String livenessAttribute = _tracker.getFacialAttribute(0, _id, "Liveness");
      _liveness = GetValueConfidence(livenessAttribute, "Liveness");

      String livenessQualityAttribute = _tracker.getFacialAttribute(0, _id, "ImageQuality");
      double livenessQuality = GetValueConfidence(livenessQualityAttribute, "ImageQuality");

      if (livenessQuality < 0.5) {
        _livenessError = "Image quality is too low";
        return false;
      }
    } on FSDK.AttributeNotDetectedError {
    }

    try {
      String livenessErrorAttribute = _tracker.getFacialAttribute(0, _id, "LivenessError");
      _livenessError = livenessErrorAttribute.substring(14, livenessErrorAttribute.length - 2);
    } on FSDK.AttributeNotDetectedError {
    }
    return _liveness! > 0.5;
  }
}

enum _FaceTrackerState {
  notInitialized, initializing, waitingForImage, waitingForIds, idsReady
}

class FaceMatchResult {
  final String name;
  final int id;
  final double similarity;
  FaceMatchResult(this.name, this.id, this.similarity);
}

class FacesTracker extends ChangeNotifier {

  static const _path = 'tracker.bin';

  String _trackerPath = "";  
  _FaceTrackerState _state = _FaceTrackerState.notInitialized;

  late SendPort _send;
  late Isolate _isolate;
  late Image _fsdkImage;

  final _tracker = Tracker();
  final _receive = ReceivePort();
  final _converter = ImageConverter();
  final _ids = Int64Buffer.allocate(5);

  late bool _useNewDetection = false;

  int _faceDetectionVersion = 1;

  int get width => _converter.width;
  int get height => _converter.height;

  FacesTracker();

  void saveTracker() {
    _tracker.saveToFile(_trackerPath);
  }

  set useNewDetection(bool use) => _useNewDetection = use;

  @override
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);

    _converter.free();    

    saveTracker();
    _tracker.free();

    super.dispose();
  }

  Future<void> _openTracker() async {
    final directory = await getApplicationDocumentsDirectory();
    _trackerPath = '${directory.path}/$_path';

    try {
      Tracker.fromFile(_trackerPath, tracker: _tracker);
      _faceDetectionVersion = int.parse(_tracker.getParameter("DetectionVersion"));
    } on Error {
      // Couldn't load tracker from memory, file may not exist
      _faceDetectionVersion = _useNewDetection == true ? 2 : 1;
    }

    _setTrackerParameters();
  }
  
  void _setTrackerParameters() {

    if (_useNewDetection) {
      _tracker.setMultipleParameters({
        'FaceDetection2PatchSize': 256,
        'Threshold': 0.8,
        'Threshold2': 0.9
      });
    } else {
      _tracker.setMultipleParameters({
        'HandleArbitraryRotations': false,
        'DetermineFaceRotationAngle': false,
        'InternalResizeWidth': 256,
        'FaceDetectionThreshold': 5
      });
    }

    // Setting parameters for iBeta liveness plugin
    _tracker.setMultipleParameters({
      'DetectLiveness': true,
      'SmoothAttributeLiveness': false,
      'LivenessFramesCount': 1
    });

    if ((_useNewDetection && _faceDetectionVersion != 2) || (!_useNewDetection && _faceDetectionVersion != 1)) {
      throw Exception('Mismatched face detection version in tracker');
    }
    
    try {
      _tracker.setParameter("DetectionVersion", _faceDetectionVersion.toString());
    } on FSDK.FailedError {}
  
  }

  static void _worker(_FacesTrackerIsolateInfo info) {
    final sendPort = info.port;
    final tracker = Tracker.fromHandle(info.trackerHandle);
    final ids = Int64Buffer.fromInfo(info.idsBufferInfo);

    final receivePort = ReceivePort();
    receivePort.listen((data) {
      var image = Image.fromHandle(data.image);

      final rotation = Platform.isAndroid ? data.orientation ~/ 90 : -(data.orientation ~/ 90) + 1;

      if (rotation != 0) {
        var rotatedImage = image.rotate90(rotation);
        image.free();
        image = rotatedImage;
      }

      if (data.frontFacing && !Platform.isIOS) {
        image.mirror(true);
      }

      ids.length = 0;      
      try {
        tracker.feedFrame(0, image, ids: ids);
      } on FaceNotFoundError {
        /*No faces were found*/
      }
      
      image.free();
      sendPort.send(null);
    });

    sendPort.send(receivePort.sendPort);
  }

  void _initialize() async {
    await _openTracker();

    _receive.listen((msg) {
      if (msg is SendPort) {
        _send = msg;

        _state = _FaceTrackerState.waitingForImage;
        return;
      }

      _state = _FaceTrackerState.idsReady;
      notifyListeners();
    });

    _isolate = await Isolate.spawn(_worker, 
      _FacesTrackerIsolateInfo(
        _receive.sendPort,
        _tracker.handle,
        _ids.getInfo()
      )
    );
  }

  void process(CameraImage image, int orientation, bool frontFacing) {
    if (_state == _FaceTrackerState.notInitialized) {
      _state = _FaceTrackerState.initializing;
      _initialize();
      return;
    }

    if (_state != _FaceTrackerState.waitingForImage) {
      return;
    }

    _state = _FaceTrackerState.waitingForIds;
    _fsdkImage = _converter.convert(image);
    _send.send(_WorkerData(_fsdkImage.handle, orientation, frontFacing));
  }

  List<FaceWrapper> faces() {
    if (_state != _FaceTrackerState.idsReady) {
      return <FaceWrapper>[];
    }

    return _ids.map((id) => FaceWrapper(id, _tracker)).toList(growable: false);
  }

  void resetTracker() {
    _tracker.clear();
    _setTrackerParameters();
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

  FaceMatchResult matchFace(Image img) {
    FSDK.FaceTemplate faceTemplate = _useNewDetection ? FSDK.GetFaceTemplate2(img) : FSDK.GetFaceTemplate(img);
    
    var similarityResults = _tracker.matchFaces(faceTemplate, _useNewDetection ? 0.7 : 0.992);

    if (similarityResults.isNotEmpty) {
      final id = similarityResults[0].id;
      final similarity = similarityResults[0].similarity;

      String name = getNameForId(id);

      return FaceMatchResult(name, id, similarity);
    }
     
    return FaceMatchResult("", -1, 0.0);
  }

  void next() {
    if (_state == _FaceTrackerState.idsReady) {
      _state = _FaceTrackerState.waitingForImage;
    }
  }

}
