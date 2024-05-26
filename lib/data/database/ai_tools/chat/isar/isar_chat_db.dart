// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:open_ai_utilities/data/database/isar/isar_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';

import '../chat_db.dart';
import 'isar_chat.dart';

class IsarChatDB implements ChatDB {
  IsarChatDB(Ref ref) : _isarService = ref.read(isarServiceProvider);

  final IsarService _isarService;

  @override
  Future<Chat?> getChat(int chatId) async {
    final isar = await _isarService.get();

    final chat = await isar.isarChats.get(chatId);

    if (chat != null) {
      return Chat(
        id: chat.id,
        creationDate: chat.creationDate!,
        model: chat.model!,
      );
    }

    return null;
  }

  @override
  Future<Chat> putChat(Chat chat) async {
    final isar = await _isarService.get();

    final p = IsarChat()
      ..creationDate = chat.creationDate
      ..model = chat.model;

    if (chat.id != 0) {
      p.id = chat.id;
    }

    final id = await isar.writeTxn(() async {
      return await isar.isarChats.put(p);
    });

    return chat.copyWith(id: id);
  }

  @override
  Future<List<Chat>> getChats() async {
    final isar = await _isarService.get();

    final chats = await isar.isarChats.where().findAll();

    return chats
        .map((e) => Chat(
              id: e.id,
              creationDate: e.creationDate!,
              model: e.model!,
            ))
        .toList();
  }

  @override
  Future<bool> deleteChat(int chatId) async {
    final isar = await _isarService.get();

    return await isar.writeTxn(() async {
      return isar.isarChats.delete(chatId);
    });
  }
}
