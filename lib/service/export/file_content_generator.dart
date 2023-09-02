import 'dart:typed_data';

import 'package:been/model/pin.dart';
import 'package:been/service/export/strategies/export_format_csv_strategy.dart';
import 'package:been/service/export/strategies/export_format_strategy.dart';

enum FileImportType { csv }

class FileContentGenerator {
  static List<ExportFormatStrategy> strategies = [
    ExportFormatCsvStrategy(),
  ];

  FileContentGenerator._();

  factory FileContentGenerator() => _privateConstructor;
  static final _privateConstructor = FileContentGenerator._();

  Future<Uint8List> convertToUint8List(
      List<Pin> pins, FileImportType fileType) {
    return strategies
        .firstWhere((todo) => todo.getFileType() == fileType)
        .generateContent(pins);
  }
}
