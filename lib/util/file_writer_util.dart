import 'dart:io';

class FileWriterUtil {
  writeOnFile(Set<String> data) async {
    final File file = File("./text.txt");
    var test = file.openWrite();
    for (var element in data) {
      test.writeln(
          "    - assets/images/flags-1000/${element.toLowerCase()}.png");
    }
    test.close();
  }
}
