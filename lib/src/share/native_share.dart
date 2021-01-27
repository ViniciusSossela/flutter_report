import 'package:esys_flutter_share/esys_flutter_share.dart';

Future<void> share(List<int> encodedData, String fileName, String fileExtension,
        {String desc = ''}) async =>
    await Share.file(
      fileName,
      '$fileName.$fileExtension',
      encodedData,
      '*/*',
      text: desc,
    );
