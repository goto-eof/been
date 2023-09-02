import 'dart:typed_data';

import 'package:been/model/pin.dart';
import 'package:been/service/export/file_content_generator.dart';

abstract class ExportFormatStrategy {
  Future<Uint8List> generateContent(List<Pin> pins);
  FileType getFileType();
}
