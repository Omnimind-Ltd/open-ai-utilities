// Copyright (c) 2024. Omnimind Ltd.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:open_ai_utilities/data/services/file/file_service.dart';

class FileServiceImpl extends FileService {
  @override
  Future<void> saveBytes(
      {required Uint8List bytes, required String fileName}) async {
    final blob = html.Blob(
        [bytes.buffer.asUint8List()], 'application/octet-stream', 'native');

    // Create an Anchor Element
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    // Clean up: Release the object URL to avoid memory leaks
    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<void> saveString(
      {required String content, required String fileName}) async {
    final blob = html.Blob([content], 'text/plain', 'native');
    final anchor =
        html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob))
          ..setAttribute('download', fileName)
          ..click();
    html.Url.revokeObjectUrl(anchor.href!);
  }
}
