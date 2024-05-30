// Copyright (c) 2024. Omnimind Ltd.

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'file_service.dart';

class FileServiceImpl extends FileService {
  @override
  Future<void> saveBytes(
      {required Uint8List bytes, required String fileName}) async {
    var outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save to:',
      fileName: fileName,
    );

    if (outputFile != null) {
      File(outputFile).writeAsBytesSync(bytes);
    }
  }

  @override
  Future<void> saveString(
      {required String content, required String fileName}) async {
    var outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save to:',
      fileName: fileName,
    );

    if (outputFile != null) {
      File(outputFile).writeAsStringSync(content);
    }
  }
}
