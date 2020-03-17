import 'package:camera/camera.dart';
import 'package:circadiandetector/circadian_detector_home.dart';
import 'package:flutter/material.dart';

import 'dart:async';

Future<void> main() async {
// Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  List<CameraDescription> cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.

  runApp(MyApp(camera: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> camera;

  const MyApp({Key key, this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Circadian Detector",
      theme: ThemeData(
        primaryColor: Color(0xff075e54),
        accentColor: Color(0xff25d366),
      ),
      debugShowCheckedModeBanner: false,
      home: new CircadianDetector(camera: camera),
    );
  }
}
