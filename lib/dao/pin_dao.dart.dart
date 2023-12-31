import 'package:been/dao/db.dart';
import 'package:been/exception/dao_exception.dart';
import 'package:been/model/pin.dart';
import 'package:been/model/district.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PinDao {
  final tableName = "pin";

  Future<int> insert(Pin pin) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();
      return await database.insert(
        tableName,
        pin.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<List<Pin>> byCountry(int countryId) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select c.name as city, r.name as region, co.name as country, p.id, p.name, p.insert_date_time, p.city_id, p.latitude, p.longitude, p.address from pin as p, city as c, region as r, country as co where p.city_id = c.id and c.region_id = r.id and r.country_id = co.id and co.id = ?",
          [countryId]);

      return List.generate(
        maps.length,
        (i) {
          return Pin(
            id: maps[i]['id'],
            cityId: maps[i]["city_id"],
            name: maps[i]['name'],
            address: maps[i]["address"],
            latitude: maps[i]["latitude"],
            longitude: maps[i]["longitude"],
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

  Future<List<Pin>> byRegion(final District region) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        orderBy: 'insert_date_time desc',
        where: 'region_id = ?',
        whereArgs: [region.id],
      );

      return List.generate(
        maps.length,
        (i) {
          return Pin(
            id: maps[i]['id'],
            cityId: maps[i]["city_id"],
            name: maps[i]['name'],
            address: maps[i]["address"],
            latitude: maps[i]["latitude"],
            longitude: maps[i]["longitude"],
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

  Future<Pin?> getByLatLong(double latitude, double longitude) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        orderBy: 'insert_date_time desc',
        where: 'latitude = ? and longitude = ?',
        whereArgs: [latitude, longitude],
      );

      if (maps.isNotEmpty) {
        Pin(
          address: maps[0]['address'],
          latitude: maps[0]['latitude'],
          longitude: maps[0]['longitude'],
          id: maps[0]['id'],
          cityId: maps[0]["city_id"],
          name: maps[0]['name'],
          insertDateTime: DateTime.parse(
            maps[0]['insert_date_time'],
          ),
        );
      }

      return null;
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<int> countByCity(int cityId) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select count(1) as num from pin where city_id = ?", [cityId]);

      if (maps.isEmpty) {
        return 0;
      }
      return maps[0]["num"];
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<int> countByCountry(int countryId) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select count(1) as num from pin as p,  city as c, region as r where  p.city_id = c.id and c.region_id = r.id and r.country_id = ?",
          [countryId]);

      if (maps.isEmpty) {
        return 0;
      }
      return maps[0]["num"];
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<int> countByDistrict(int districtId) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select count(1) as num from pin as p, city as c, region as r where p.city_id = c.id and c.region_id = r.id and r.id = ?",
          [districtId]);
      print(maps);
      if (maps.isEmpty) {
        return 0;
      }
      return maps[0]["num"];
    } catch (err) {
      print("$err");
      throw DaoException(cause: err.toString());
    }
  }

  Future<int> count() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps =
          await database.rawQuery("select count(1) as num from pin");

      if (maps.isEmpty) {
        return 0;
      }
      return maps[0]["num"];
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<List<Pin>> list(int cityId) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        orderBy: 'insert_date_time desc',
        where: 'city_id = ?',
        whereArgs: [cityId],
      );

      return List.generate(
        maps.length,
        (i) {
          return Pin(
            id: maps[i]['id'],
            cityId: maps[i]["city_id"],
            name: maps[i]['name'],
            address: maps[i]["address"],
            latitude: maps[i]["latitude"],
            longitude: maps[i]["longitude"],
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

  Future<List<Pin>> listAll() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();
      final List<Map<String, dynamic>> maps = await database.rawQuery(
          "select c.name as city, r.name as region, co.name as country, p.id, p.name, p.insert_date_time, p.city_id, p.latitude, p.longitude, p.address from pin as p, city as c, region as r, country as co where p.city_id = c.id and c.region_id = r.id and r.country_id = co.id");

      return List.generate(
        maps.length,
        (i) {
          return Pin(
            id: maps[i]['id'],
            cityId: maps[i]["city_id"],
            name: maps[i]['name'],
            address: maps[i]["address"],
            latitude: maps[i]["latitude"],
            longitude: maps[i]["longitude"],
            city: maps[i]["city"],
            region: maps[i]["region"],
            country: maps[i]["country"],
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

  void truncate() async {
    DB db = DB();
    final database = await db.getDatabaseConnection();
    await database.execute("delete from pin");
  }
}
