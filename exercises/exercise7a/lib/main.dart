import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await flutterLocalNotificationsPlugin.initialize(InitializationSettings(android: androidSettings));

  final cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({required this.camera, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceCam',
      theme: ThemeData.dark(),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({required this.camera, super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takeAndProcessPicture() async {
    await _initializeControllerFuture;
    final image = await _controller.takePicture();
    final imagePath = image.path;

    final inputImage = InputImage.fromFilePath(imagePath);
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    final faces = await faceDetector.processImage(inputImage);
    faceDetector.close();

    if (faces.isNotEmpty) {
      const androidDetails = AndroidNotificationDetails(
        'face_detected', 'Face Detection', importance: Importance.max, priority: Priority.high);
      const notificationDetails = NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.show(
        0, 'Face Detected', 'A human face was detected!', notificationDetails);
    }

    final file = File(imagePath);
    final ref = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DisplayImage(imagePath: imagePath)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? CameraPreview(_controller)
              : const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takeAndProcessPicture,
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class DisplayImage extends StatelessWidget {
  final String imagePath;
  const DisplayImage({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
