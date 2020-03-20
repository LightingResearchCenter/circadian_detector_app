import 'package:camera/camera.dart';
import 'package:circadiandetector/pages/maps_screen.dart';
import 'package:circadiandetector/pages/status_screen.dart';
import 'package:circadiandetector/pages/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


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
          Icon(Icons.search),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
          IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {

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
      floatingActionButton: showFab
          ? FloatingActionButton(
          backgroundColor: Theme
              .of(context)
              .accentColor,
          child: Icon(
            Icons.message,
            color: Colors.white,
          ),
          onPressed: () {
            print('Open Database');

          }
      )
          : null,
    );
  }
}
