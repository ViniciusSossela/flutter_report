import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> share(List<int> encodedData, String fileName, String fileExtension,
    {String desc = ''}) async {
  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/$fileName.$fileExtension').create();
  await file.writeAsBytes(encodedData);

  await Share.share(file.path, subject: desc);
}
