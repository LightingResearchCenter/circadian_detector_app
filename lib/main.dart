import 'package:camera/camera.dart';
import 'package:circadiandetector/circadian_detector_home.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:circadiandetector/database_helper.dart';

Future<void> main() async {
// Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  List<CameraDescription> cameras = await availableCameras();

  var db = await openDatabase('CircadianDatabase.db', version: 1,
      onCreate: (Database database, int version) async {
    await database.execute('''
CREATE TABLE Data ( 
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  datetime TEXT NOT NULL,
  lat REAL NOT NULL,
  lon REAL NOT NULL,
  red REAL NOT NULL,
  green REAL NOT NULL,
  blue REAL NOT NULL,
  shutterSpeed REAL NOT NULL,
  iso REAL NOT NULL,
  cs REAL NOT NULL)
''');
  });

  // Get a specific camera from the list of available cameras.

  runApp(MyApp(camera: cameras, database: db));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> camera;
  final Database database;

  const MyApp({Key key, this.camera, this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Circadian Detector",
      theme: ThemeData(
        primaryColor: Color(0xff075e54),
        accentColor: Color(0xff25d366),
      ),
      debugShowCheckedModeBanner: false,
      home: new CircadianDetector(camera: camera, database: database),
    );
  }
}
