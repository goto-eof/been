import 'dart:io';

class FileWriter {
  writeOnFile(Set<String> data) async {
    final File file = File("./text.txt");
    var test = file.openWrite();
    for (var element in data) {
      test.writeln("    - assets/images/flags/${element.toLowerCase()}.png");
    }
    test.close();
  }
}
