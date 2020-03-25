import 'package:camera/camera.dart';
import 'package:circadiandetector/pages/maps_screen.dart';
import 'package:circadiandetector/pages/status_screen.dart';
import 'package:circadiandetector/pages/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:sqflite_porter/utils/csv_utils.dart';

class CircadianDetector extends StatefulWidget {
  final List<CameraDescription> camera;
  final Database database;

  const CircadianDetector({Key key, this.camera, this.database})
      : super(key: key);

  @override
  _CircadianDetectorState createState() => _CircadianDetectorState();
}

class _CircadianDetectorState extends State<CircadianDetector>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool showFab = true;

  _CircadianDetectorState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 1, length: 3);
    _tabController.addListener(() {
      if (_tabController.index >= 1) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Circadian Detector"),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.camera_alt)),
            Tab(text: "STATUS"),
            Tab(text: "MAP"),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              exportDatabase(widget.database);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          CameraScreen(widget.camera, widget.database),
          StatusScreen(widget.database),
          MapsScreen(),
        ],
      ),
    );
  }

  void exportDatabase(Database db) async {
    var result = await db.query('data');
    var csv = mapListToCsv(result);
    print("Exporting Database");
    final Email email = Email(
      body: csv,
      subject: 'Circadian Data ${DateTime.now().toIso8601String()}',
      isHTML: true,
    );
    await FlutterEmailSender.send(email);
  }
}
