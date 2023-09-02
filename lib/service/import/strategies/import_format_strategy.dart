import 'package:been/model/pin.dart';
import 'package:been/service/import/file_content_loader.dart';

abstract class ImportFormatStrategy {
  Future<List<Pin>> loadContent(String fileNameAndPath);
  ImportFileType getFileType();
}
