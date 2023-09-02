import 'dart:convert';
import 'dart:io';

import 'package:been/model/pin.dart';
import 'package:been/service/import/file_content_loader.dart';
import 'package:been/service/import/strategies/import_format_strategy.dart';
import 'package:csv/csv.dart';

class ImportFormatCsvStrategy implements ImportFormatStrategy {
  @override
  ImportFileType getFileType() {
    return ImportFileType.csv;
  }

  @override
  Future<List<Pin>> loadContent(String fileNameAndPath) async {
    final input = File(fileNameAndPath).openRead();
    final rows = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    var pins = rows
        .skip(1)
        .map(
          (fields) => Pin(
            longitude: double.parse(fields[0]),
            latitude: double.parse(fields[1]),
            city: fields[2],
            region: fields[3],
            country: fields[4],
            address: fields[5],
          ),
        )
        .toList();

    return pins;
  }
}
