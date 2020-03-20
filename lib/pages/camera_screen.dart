import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:sqflite/sqflite.dart';
import 'package:circadiandetector/database_helper.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Database database;

  CameraScreen(this.cameras, this.database);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras.first, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Center(
        child: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: () async {
            //Take the picture in a try/ catch block. If anything goes wrong
            //catch the error
            try {
              await _initializeControllerFuture;
              var image =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              var currentLocation = await Geolocator()
                  .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//              final path = join(
//                (await getApplicationDocumentsDirectory()).path,
//                '${DateTime.now()}.jpg',
//              );
//              await _controller.takePicture(path);
              if (image != null) {
                Map<String, IfdTag> data = await readExifFromBytes(
                    await new File(image.path).readAsBytes());
//                for (String key in data.keys) {
//                  print("$key (${data[key].tagType}): ${data[key]}");
//                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imagePath: image.path,
                      currentLocation: currentLocation,
                      exifData: data,
                      database: widget.database,
                    ),
                  ),
                );
              }
            } catch (e) {
              //If an error occurs, log the error to the console.
              print(e);
            }
          },
        ),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Position currentLocation;
  final Map<String, IfdTag> exifData;
  final Database database;

  const DisplayPictureScreen(
      {Key key,
      this.imagePath,
      this.currentLocation,
      this.exifData,
      this.database})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    var img = Image.file(File(widget.imagePath));
    image.Image img2 =
        image.decodeImage(File(widget.imagePath).readAsBytesSync());
    var location = widget.currentLocation;

    var r = 0;
    var g = 0;
    var b = 0;
    var a = 0;
    var totpix = 0;
    for (var x = 1; x < img2.width; x++) {
      for (var y = 1; y < img2.height; y++) {
        var pixel = img2.getPixel(x, y);
        r = r + image.getRed(pixel);
        g = g + image.getGreen(pixel);
        b = b + image.getBlue(pixel);
        a = a + image.getAlpha(pixel);
        totpix++;
      }
    }
    var ravg = r / totpix;
    var gavg = g / totpix;
    var bavg = b / totpix;
    var aavg = a / totpix;
    var shutterSpeed = widget.exifData['EXIF ShutterSpeedValue'];
    var iso = widget.exifData['EXIF ISOSpeedRatings'];
    var wid = <Widget>[
      img,
      Text("RGBA = ($ravg, $gavg, $bavg, $aavg)"),
      Text("Location = (${location.latitude},${location.longitude})")
    ];
    for (String key in widget.exifData.keys) {
      wid.add(Text(
          "$key (${widget.exifData[key].tagType}): ${widget.exifData[key]}"));
    }
    Data entry = Data(
        dateTime: DateTime.now(),
        lat: location.latitude,
        lon: location.longitude,
        red: ravg,
        green: gavg,
        blue: bavg,
        shutterSpeed: shutterSpeed.toString(),
        iso: iso.toString(),
        cs:(ravg+gavg+bavg)/3/255*0.7,
    );
    print(entry.toMap().toString());
    print(widget.database.insert('data', entry.toMap()));

    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: ListView(
        children: wid,
      ),
    );
  }
}
