import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_sdk/flutter_face_sdk.dart' as FSDK;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'faces_tracker.dart' show FacesTracker;

const luxandURL = 'https://www.luxand.com/facesdk';
const luxandSwatch = MaterialColor(
  0xff5a95dd,
  <int, Color>{
    50:  Color(0xffa4c4ec),
    100: Color(0xff9cbfea),
    200: Color(0xff8bb4e7),
    300: Color(0xff7baae3),
    400: Color(0xff6a9fe0),
    500: Color(0xff5a95dd),
    600: Color(0xff5187c7),
    700: Color(0xff4878b1),
    800: Color(0xff3f699b),
    900: Color(0xff365a85)
  }
);


bool useNewDetection = true;

bool _hasStoragePermission = false;
late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  _hasStoragePermission = await Permission.storage.request().isGranted;

  runApp(const LiveRecognitionApp());
}


class LiveRecognitionApp extends StatelessWidget {

  const LiveRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Recognition',
      theme: ThemeData(
        primarySwatch: luxandSwatch,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CameraPage(title: 'Live Recognition Home Page'),
    );
  }

}


class CameraPage extends StatefulWidget {

  final String title;

  const CameraPage({super.key, this.title = ''});

  @override
  CameraPageState createState() => CameraPageState();

}

class CameraPageState extends State<CameraPage> {

  bool _initialized = false;

  @override
  Widget build(BuildContext context) {

    if (!_initialized) {
      try {
        FSDK.ActivateLibrary('INSERT THE LICENSE KEY HERE');
        FSDK.InitializeLibrary();

        // Initialize the iBeta liveness plugin
        FSDK.PrepareData().then((dataDirectory) {
          FSDK.SetParameter("LivenessModel", "external:dataDir=$dataDirectory/");
          _initialized = true;
        });

      } on FSDK.NotActivatedError {
        return const AlertDialog(
          title: Text('Activation error'),
          content: Text('FaceSDK wasn\'t activated. Please check your license'),
        );
      } on FSDK.Error catch (e) {
        return AlertDialog(
          title: const Text('Initialization error'),
          content: Text('Error initializing FaceSDK\n${e.callee} -> ${e.code}'),
        );
      }
    }

    return const Scaffold(
      body: FaceRecognitionPreview()
    );
  }
}


class FaceRect extends Rect {

  final int _id;
  int get id => _id;

  FaceRect(int id, super.a, super.b) : _id = id, super.fromPoints();
}

class FacesPainter extends CustomPainter {

  static const _drawFPS = true;
  static const _drawFeatures = false;

  static final _paintGreen = Paint()..color = Colors.green;
  static final _paintBlue  = Paint()..color = Colors.blue  ..style = PaintingStyle.stroke ..strokeWidth = 3;

  final _faces       = <FaceRect>[];
  final _stopwatch   = Stopwatch()..start();
  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  final FacesTracker _tracker;
  final CameraController _controller;

  FacesPainter(FacesTracker tracker, CameraController controller) : _tracker = tracker, _controller = controller, super(repaint: tracker);

  @override
  void paint(Canvas canvas, Size size) {
    final int width;
    final int height;

    final extra = Platform.isIOS ? 90 : 0;

    if ((_controller.description.sensorOrientation + extra) % 180 != 0) {
      width  = _tracker.height;
      height = _tracker.width;
    } else {
      width  = _tracker.width;
      height = _tracker.height;
    }

    final wc = size.width / width;
    final hc = size.height / height;

    final scale = min(wc, hc);
    final offsetX = (size.width  - width  * scale) / 2;
    final offsetY = (size.height - height * scale) / 2;

    _faces.clear();

    try {
      for (final face in _tracker.faces()) {

        FaceRect rect;

        if (useNewDetection) {
          final facePosition = face.face;
          
          final tl = Offset(facePosition.left.toDouble(), facePosition.top.toDouble()).scale(scale, scale).translate(offsetX, offsetY);
          final br = Offset(facePosition.right.toDouble(), facePosition.bottom.toDouble()).scale(scale, scale).translate(offsetX, offsetY);
          rect = FaceRect(face.id, tl, br);  
        } else {
          final position = face.position;

          final tl = Offset(position.xc - position.w / 2, position.yc - position.w / 2).scale(scale, scale).translate(offsetX, offsetY);
          final br = Offset(position.xc + position.w / 2, position.yc + position.w / 2).scale(scale, scale).translate(offsetX, offsetY);
          rect = FaceRect(face.id, tl, br);  
        }

        _faces.add(rect);
        canvas.drawRect(rect, _paintBlue);

        if (_drawFeatures) {
          for (final point in face.features) {
            canvas.drawCircle(Offset(point.x.toDouble(), point.y.toDouble()).scale(scale, scale).translate(offsetX, offsetY), 2, _paintGreen);
          }
        }
        
        final name = face.name;
        if (name.isNotEmpty) {
          _textPainter.text = TextSpan(text: name);
          _textPainter.layout();
          _textPainter.paint(canvas, rect.bottomCenter.translate(-_textPainter.width / 2, 10));
        }

        bool live = face.checkLiveness();

        double liveness = face.liveness;
        String livenessError = face.livenessError;

        String livenessText = "Liveness: ${liveness.toStringAsFixed(3)}";
        if (livenessError.isNotEmpty) {
          livenessText += " error: $livenessError";
        }

        _textPainter.text = TextSpan(
          text: livenessText,
          style: TextStyle(
            color: live ? Colors.lightGreen : Colors.red,
            fontSize: 14
          )
        );
        _textPainter.layout();
        _textPainter.paint(canvas, const Offset(10, 30));

      }
    } on FSDK.IdNotFoundError {
     // Tracker was cleared before previous ids were processed
    }

    if (_drawFPS) {
      _textPainter.text = TextSpan(
        text: (1000 / _stopwatch.elapsedMilliseconds).toStringAsFixed(1),
        style: const TextStyle(
          fontSize: 18,
          color: Colors.lightGreen,
          fontWeight: FontWeight.bold
        )
      );
      _textPainter.layout();
      _textPainter.paint(canvas, const Offset(10, 10));
    }

    _stopwatch.reset();
    _tracker.next();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  FaceRect? getFaceRect(Offset position) {
    for (final rect in _faces) {
      if (rect.contains(position)) {
        return rect;
      }
    }

    return null;
  }

}


class FaceRecognitionPreview extends StatefulWidget {

  const FaceRecognitionPreview({super.key});

  @override
  State<StatefulWidget> createState() => _FaceRecognitionPreviewState();

}


class _FaceRecognitionPreviewState extends State<FaceRecognitionPreview> with WidgetsBindingObserver {

  final _tracker = FacesTracker();

  final _buttonStyle = ElevatedButton.styleFrom(
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold
    ),
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
  );  

  late FacesPainter _painter;  
  late CameraController _controller;

  CameraLensDirection _lens = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();

    _tracker.useNewDetection = useNewDetection;

    WidgetsBinding.instance.addObserver(this);

    _controller = _getCameraController();
    _painter = FacesPainter(_tracker, _controller);

    _openCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _tracker.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _tracker.saveTracker();
    }

    if (!_controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _closeCamera();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _openCamera();
      return;
    }
  }

  void _switchLens() {
    _lens =
      _lens == CameraLensDirection.front
      ? CameraLensDirection.back
      : CameraLensDirection.front;
  }

  CameraController _getCameraController() {
    return CameraController(_getCamera(), ResolutionPreset.high, enableAudio: false);
  }

  CameraDescription _getCamera() {
    return _cameras.firstWhere(
      (element) => element.lensDirection == _lens,
      orElse: () => _cameras[0]
    );
  }

  void _process(CameraImage image) {
    _tracker.process(image, _controller.description.sensorOrientation, _lens == CameraLensDirection.front);
  }

  Future _closeCamera() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
    }

    await _controller.dispose();
  }

  void _openCamera() async {
    await _closeCamera();

    _controller = _getCameraController();
    await _controller.initialize();
    await _controller.startImageStream(_process);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top:20.0, bottom: 20.0),
          alignment: Alignment.center,
          child: GestureDetector(
            onTapUp: (detail) async {
              final maybeRect = _painter.getFaceRect(detail.localPosition);
              if (maybeRect == null) {
                return;
              }

              final rect = maybeRect;
              
              final name = _tracker.getNameForId(rect.id);
              final controller = TextEditingController(text: name);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Change name'),
                    ),
                    body: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                              controller: controller
                          )
                        ),
                        OverflowBar(
                          alignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ElevatedButton(
                              style: _buttonStyle,
                              child: const Text('Save'),
                              onPressed: () => Navigator.pop(context, true),
                            )
                          ],
                        )
                      ],
                    )
                  )
                )
              ) ?? false;

              if (result) {
                _tracker.setNameForId(rect.id, controller.text);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CameraPreview(_controller),
                CustomPaint(
                  painter: _painter,
                  child: Container()
                )
              ]
            ),
          )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: OverflowBar(
            alignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                style: _buttonStyle,
                child: const Text('Match'),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {

                    String titleText = "";
                    String contentText = "";
                    try {
                      final img = FSDK.Image.fromFile(image.path);
                      final matchResult = _tracker.matchFace(img);
                      if (matchResult.name.isEmpty) {
                        titleText = "No match";
                        contentText = "Can not find this face in the tracker DB.";
                      } else {
                        titleText = "Face found!";
                        contentText = "The face matched with ${matchResult.name}, id: ${matchResult.id}, similarity: ${matchResult.similarity}";
                      }
                    } on FSDK.FaceNotFoundError {
                      titleText = "Error";
                      contentText = "Face not found";
                    } catch (e) {
                      titleText = "Error";
                      contentText = e.toString();
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(titleText),
                        content: Text(contentText),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              ElevatedButton(
                style: _buttonStyle,
                child: const Text('Flip'),
                onPressed: () {
                  _switchLens();
                  _openCamera();
                },
              ),
              ElevatedButton(
                style: _buttonStyle,
                child: const Text('Help'),                
                onPressed: () => showAboutDialog(
                  context: context,
                  applicationIcon: const Image(image: AssetImage('graphics/icon.png')),
                  applicationName: 'Live Recognition',
                  applicationVersion: 'FaceSDK',
                  applicationLegalese: '© Luxand, Inc.',
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(
                            text:
                              '\nJust tap any detected face and name it. '
                              'The app will recognize this face further. '
                              'For best results, hold the device at arm\'s length. '
                              'You may slowly rotate the head for the app to memorize you at multiple views. '
                              'The app can memorize several persons. '
                              'If a face is not recognized, tap and name it again.\n\n'
                          ),
                          const TextSpan(
                            text: 'The SDK is available for developers: '
                          ),
                          TextSpan(
                            text: luxandURL,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline
                            ),
                            recognizer: TapGestureRecognizer() ..onTap = () => launchUrl(Uri.parse(luxandURL))
                          )
                        ]
                      )
                    )
                  ]
                ),
              ),
              ElevatedButton(
                style: _buttonStyle,
                child: const Text('Clear'),
                onPressed: () => _tracker.resetTracker(),
              ),
            ],
          )
        )
      ],
    );
  }
}
