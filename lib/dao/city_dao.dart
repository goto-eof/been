import 'package:been/dao/db.dart';
import 'package:been/model/city.dart';
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
        numberOfChilds: 0,
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

  Future<int> getPins(final int cityId) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.rawQuery(
        "select count(1) as num from pin, city where pin.city_id = city.id and  pin.city_id = ?",
        [cityId]);

    if (maps.isEmpty) {
      return 0;
    }
    return maps[0]["num"];
  }

  Future<City?> getByCityNameAndRegionId(
      String regionName, int regionId) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      orderBy: 'insert_date_time desc',
      where: 'region_id = ? and name = ?',
      whereArgs: [regionId, regionName],
    );

    if (maps.isNotEmpty) {
      return City(
        numberOfChilds: 0,
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
