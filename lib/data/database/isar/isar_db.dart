// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../ai_tools/chat/isar/isar_chat.dart';
import '../ai_tools/messages/isar/isar_message.dart';
import '../ai_tools/prompts/isar/isar_prompt.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarServiceImpl());

abstract class IsarService {
  FutureOr<Isar> get();
}

class IsarServiceImpl extends IsarService {
  Isar? _isar;

  @override
  FutureOr<Isar> get() async {
    if (_isar == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          IsarChatSchema,
          IsarMessageSchema,
          IsarPromptSchema,
        ],
        name: 'open-ai-utils',
        directory: dir.path,
        inspector: kDebugMode,
      );
    }

    return _isar!;
  }
}
