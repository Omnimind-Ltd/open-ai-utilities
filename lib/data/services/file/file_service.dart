// Copyright (c) 2024. Omnimind Ltd.

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'file_service_impl_native.dart'
    if (dart.library.js) 'file_service_impl_web.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  return FileServiceImpl();
});

abstract class FileService {
  Future<void> saveString({required String content, required String fileName});

  Future<void> saveBytes({required Uint8List bytes, required String fileName});
}
