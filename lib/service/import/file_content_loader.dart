import 'package:been/model/pin.dart';
import 'package:been/service/import/strategies/import_format_csv_strategy.dart';
import 'package:been/service/import/strategies/import_format_strategy.dart';

enum ImportFileType { csv }

class FileContentLoader {
  static List<ImportFormatStrategy> strategies = [
    ImportFormatCsvStrategy(),
  ];

  FileContentLoader._();

  factory FileContentLoader() => _privateConstructor;
  static final _privateConstructor = FileContentLoader._();

  Future<List<Pin>> convertToToDoList(
      final String filePathAndName, ImportFileType fileType) {
    return strategies
        .firstWhere((strategy) => strategy.getFileType() == fileType)
        .loadContent(filePathAndName);
  }
}
