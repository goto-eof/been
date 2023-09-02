import 'dart:convert';
import 'dart:typed_data';

import 'package:been/model/pin.dart';
import 'package:been/service/export/file_content_generator.dart';
import 'package:been/service/export/strategies/export_format_strategy.dart';
import 'package:csv/csv.dart';

class ExportFormatCsvStrategy implements ExportFormatStrategy {
  @override
  Future<Uint8List> generateContent(List<Pin> pins) async {
    final List<String> rowHeader = [
      "longitude",
      "latitude",
      "city",
      "district",
      "country",
      "address",
      "insertDateTime"
    ];
    List<List<dynamic>> rows = [];
    rows.add(rowHeader);
    for (Pin pin in pins) {
      List<dynamic> dataRow = [];
      dataRow.add(pin.longitude);
      dataRow.add(pin.latitude);
      dataRow.add(pin.city);
      dataRow.add(pin.region);
      dataRow.add(pin.country);
      dataRow.add(pin.address);
      dataRow.add(pin.insertDateTime!.toIso8601String());
      rows.add(dataRow);
    }
    String csv = const ListToCsvConverter().convert(rows);

    final bytes = utf8.encode(csv);
    final Uint8List unit8List = Uint8List.fromList(bytes);
    return unit8List;
  }

  @override
  FileImportType getFileType() {
    return FileImportType.csv;
  }
}
