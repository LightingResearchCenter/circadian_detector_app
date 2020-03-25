import 'package:sqflite/sqflite.dart';

class Data {
  int id;
  DateTime dateTime;
  double lat;
  double lon;
  double red;
  double green;
  double blue;
  String shutterSpeed;
  String iso;
  double cs;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'dateTime': dateTime.toString(),
      'lat': lat,
      'lon': lon,
      'red': red,
      'green': green,
      'blue': blue,
      'shutterSpeed': shutterSpeed,
      'iso': iso,
      'cs': cs,
    };
    return map;
  }

  Data({
    this.dateTime,
    this.lat,
    this.lon,
    this.red,
    this.green,
    this.blue,
    this.shutterSpeed,
    this.iso,
    this.cs,
  });

  Data.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    dateTime = DateTime.parse(map['dateTime']);
    lat = map['lat'];
    lon = map['lon'];
    red = map['red'];
    green = map['green'];
    blue = map['blue'];
    shutterSpeed = map['shutterSpeed'];
    iso = map['iso'];
    cs = map['cs'];
  }
}

class DataProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table Data ( 
  id integer primary key autoincrement, 
  datetime text not null,
  lat real not null,
  lon real not null,
  red real not null,
  green real not null,
  blue real not null,
  shutterSpeed real not null,
  iso real not null,
  cs real not null)
''');
    });
  }

  Future<Data> insert(Data data) async {
    data.id = await db.insert('data', data.toMap());
    return data;
  }

  Future<Data> getTodo(int id) async {
    List<Map> maps = await db.query('data',
        columns: [
          'id',
          'datetime',
          'lat',
          'lon',
          'red',
          'green',
          'blue',
          'shutterSpeed',
          'iso'
        ],
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Data.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete('data', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Data data) async {
    return await db
        .update('data', data.toMap(), where: 'id = ?', whereArgs: [data.id]);
  }

  Future close() async => db.close();
}
