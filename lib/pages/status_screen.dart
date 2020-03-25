import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

class StatusScreen extends StatefulWidget {
  final Database database;

  StatusScreen(this.database);

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<Map<String, dynamic>> records;

  @override
  void initState() {
    super.initState();
    getRecords(widget.database);
  }

  @override
  Widget build(BuildContext context) {
    if (records == null) {
      return ListView(
        children: <Widget>[
          Text(
            "Status Screen",
            style: TextStyle(fontSize: 20.0),
          ),
        ],
      );
    } else {
      if (records.length == 0) {
        return ListView(
          children: <Widget>[
            Text(
              "There was no data.",
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        );
      } else {
        List<Widget> wid = <Widget>[];
        for (var map in records) {
          wid.add(
            Row(
              children: <Widget>[
                Text('''${map['id']} @ ${map['datetime']}: 
 RGB (${map['red'].round()}, ${map['green'].round()},${map['blue'].round()}) 
 ShutterSpeed (${map['shutterSpeed']}) 
 ISO (${map['iso']})
 cs (${map['cs']})
 '''),
              ],
            ),
          );
        }
        return Scaffold(
          body: ListView(children: wid),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.access_alarm),
            onPressed: () {
              print("Button Pressed");
              calculateCSTimeLine(widget.database, 30);
            },
          ),
        );
      }
    }
  }

  void getRecords(db) async {
    var results = await db.query('data');
    setState(() {
      records = results;
    });
  }
  void calculateCSTimeLine(Database db, int increment) async {
    var result = await db.query('data');
    print(result);
  }
}
