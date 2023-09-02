import 'package:been/util/country_util.dart';
import 'package:been/util/file_writer_util.dart';

class DevUtil {
  void writeAssetsImagesFlags() async {
    Set<String> cca2List =
        (await CountryUtil().loadCountriesData()).map((e) => e.cca2).toSet();
    await FileWriterUtil().writeOnFile(cca2List);
  }
}
