import 'package:been/dao/db.dart';
import 'package:been/exception/dao_exception.dart';
import 'package:been/model/country.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CountryDao {
  final tableName = "country";

  Future<int> insert(Country country) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();
      return await database.insert(
        tableName,
        country.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<Country?> getByName(final String countryName) async {
    try {
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
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<int?> getRegionsCount(final String countryName) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select count(1) as num from region, country where region.country_id = country.id and country.name like ?",
          [countryName]);

      if (maps.isEmpty) {
        return null;
      }
      return maps[0]["num"];
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<int> count() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps =
          await database.rawQuery("select count(1) as num from country");

      if (maps.isEmpty) {
        return 0;
      }
      return maps[0]["num"];
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<List<int>> retrieveCountriesToDelete() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select distinct c.id as id from country as c where NOT EXISTS (select d.id from region d where d.country_id = c.id)");

      if (maps.isEmpty) {
        return [];
      }
      return maps.map((e) => e["id"] as int).toList();
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<List<Country>> list() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps =
          await database.query(tableName, orderBy: 'insert_date_time desc');

      return List.generate(
        maps.length,
        (i) {
          return Country(
            numberOfChilds: 0,
            id: maps[i]['id'],
            name: maps[i]['name'],
            insertDateTime: DateTime.parse(
              maps[i]['insert_date_time'],
            ),
          );
        },
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<void> delete(int id) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      await database.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }
}
