import 'package:flutter/material.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Maps Screen",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}