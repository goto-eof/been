import 'package:been/dao/country_dao.dart';
import 'package:been/dao/db.dart';
import 'package:been/model/country.dart';
import 'package:been/model/region.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RegionDao {
  final tableName = "region";

  Future<int> insert(Region region) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();
    return await database.insert(
      tableName,
      region.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Region>> list(final String countryName) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();
    Country? country = await CountryDao().getByName(countryName);

    if (country != null) {
      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        orderBy: 'insert_date_time desc',
        where: 'country_id = ?',
        whereArgs: [country.id],
      );

      return List.generate(maps.length, (i) {
        return Region(
          id: maps[i]['id'],
          countryId: maps[i]["country_id"],
          name: maps[i]['name'],
          insertDateTime: DateTime.parse(
            maps[i]['insert_date_time'],
          ),
        );
      });
    }

    return [];
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

  Future<Region?> getByRegionNameAndCountryId(
      String regionName, int countryId) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      orderBy: 'insert_date_time desc',
      where: 'country_id = ? and name like ?',
      whereArgs: [countryId, regionName],
    );

    if (maps.isNotEmpty) {
      return Region(
        id: maps[0]['id'],
        countryId: maps[0]["country_id"],
        name: maps[0]['name'],
        insertDateTime: DateTime.parse(
          maps[0]['insert_date_time'],
        ),
      );
    }

    return null;
  }
}
