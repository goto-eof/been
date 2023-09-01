import 'package:been/dao/db.dart';
import 'package:been/model/country.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CountryDao {
  final tableName = "country";

  Future<int> insert(Country country) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();
    return await database.insert(
      tableName,
      country.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Country?> getByName(final String countryName) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      orderBy: 'insert_date_time desc',
      where: 'name = ?',
      whereArgs: [countryName],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Country(
      name: maps[0]["name"],
      id: maps[0]["id"],
      numberOfChilds: 0,
      insertDateTime: DateTime.parse(
        maps[0]["insert_date_time"],
      ),
    );
  }

  Future<int?> getRegionsCount(final String countryName) async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await database.rawQuery(
        "select count(1) as num from region, country where region.country_id = country.id and country.name like ?",
        [countryName]);

    if (maps.isEmpty) {
      return null;
    }
    return maps[0]["num"];
  }

  Future<List<Country>> list() async {
    DB db = DB();
    final database = await db.getDatabaseConnection();

    final List<Map<String, dynamic>> maps =
        await database.query(tableName, orderBy: 'insert_date_time desc');

    return List.generate(maps.length, (i) {
      return Country(
        numberOfChilds: 0,
        id: maps[i]['id'],
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
}
