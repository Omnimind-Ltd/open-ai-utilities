// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';
import 'dart:typed_data';

import 'package:open_ai_utilities/data/database/isar/isar_db.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';

import '../message_db.dart';
import 'isar_message.dart';

class IsarMessageDB extends MessageDB {
  IsarMessageDB(Ref ref) : _isarService = ref.read(isarServiceProvider);

  final IsarService _isarService;

  @override
  Future<void> deleteMessages(int chatId) async {
    final isar = await _isarService.get();

    await isar.writeTxn(() async {
      await isar.isarMessages.filter().chatIdEqualTo(chatId).deleteAll();
    });
  }

  @override
  Future<List<Message>> getMessages(int chatId) async {
    final isar = await _isarService.get();
    final messages =
        await isar.isarMessages.filter().chatIdEqualTo(chatId).findAll();

    return messages
        .map((e) => Message(
            chatId: e.chatId!,
            role: OpenAIChatMessageRole.values
                .singleWhere((element) => element.name == e.role),
            type: MessageType.values.singleWhere((t) => t.name == e.type),
            content: Uint16List.fromList(e.content!)))
        .toList();
  }

  @override
  Future<Message> putMessage(Message message) async {
    final isar = await _isarService.get();

    final m = IsarMessage()
      ..role = message.role.name
      ..type = message.type.name
      ..chatId = message.chatId
      ..content = message.content.toList(growable: false);

    if (message.id != 0) {
      m.id = message.id;
    }

    final id = await isar.writeTxn(() async {
      return await isar.isarMessages.put(m);
    });

    return message.copyWith(id: id);
  }
}
