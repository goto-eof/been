import 'package:been/dao/db.dart';
import 'package:been/model/city.dart';
import 'package:been/model/pin.dart';
import 'package:been/model/region.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CityDao {
  final tableName = "city";

  Future<int> insert(City city) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();
    return await database.insert(
      tableName,
      city.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<City>> byRegion(final Region region) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      orderBy: 'insert_date_time desc',
      where: 'region_id = ?',
      whereArgs: [region.id],
    );

    return List.generate(maps.length, (i) {
      return City(
        id: maps[i]['id'],
        regionId: maps[i]["region_id"],
        name: maps[i]['name'],
        insertDateTime: DateTime.parse(
          maps[i]['insert_date_time'],
        ),
      );
    });
  }

  Future<void> delete(int id) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<City?> getByRegionNameAndRegionId(
      String regionName, int regionId) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      orderBy: 'insert_date_time desc',
      where: 'region_id = ? and name = ?',
      whereArgs: [regionName, regionId],
    );

    if (maps.length > 0) {
      City(
        id: maps[0]['id'],
        regionId: maps[0]["region_id"],
        name: maps[0]['name'],
        insertDateTime: DateTime.parse(
          maps[0]['insert_date_time'],
        ),
      );
    }

    return null;
  }
}
