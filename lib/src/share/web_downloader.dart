import 'dart:convert';
import 'dart:html';

Future<void> share(List<int> encodedData, String fileName, String fileExtension,
        {String desc}) async =>
    AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64Encode(encodedData)}')
      ..setAttribute('download', '$fileName.$fileExtension')
      ..click();
