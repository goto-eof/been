import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  Database? db;
  static final DB _instance = DB._internal();
  factory DB() {
    return _instance;
  }

  DB._internal();

  Future<Database> getDatabaseConnection() async {
    String? directory;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir = await getApplicationSupportDirectory();
      directory = appDocumentsDir.path;
    }
    db ??= await openDatabase(
      join(directory ?? await getDatabasesPath(), 'db15.db'),
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE country(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, insert_date_time TEXT)');
        db.execute(
            'CREATE TABLE region(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, insert_date_time TEXT, country_id INT NOT NULL)');
        db.execute(
            'CREATE TABLE city(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, insert_date_time TEXT, region_id INT NOT NULL)');
        db.execute(
            'CREATE TABLE pin(id INTEGER PRIMARY KEY, name TEXT, insert_date_time TEXT, city_id INT NOT NULL, latitude DOUBLE NOT NULL, longitude DOUBLE NOT NULL, address TEXT NOT NULL UNIQUE, UNIQUE(longitude, latitude))');
      },
      onUpgrade: (db, oldVersion, newVersion) => {if (newVersion >= 2) {}},
      version: 1,
    );
    return db!;
  }
}
