// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';

import '../chat_db.dart';
import 'hive_chat.dart';

class ChatDBImpl implements ChatDB {
  ChatDBImpl(Ref ref);

  LazyBox<HiveChat>? _box;

  FutureOr<LazyBox<HiveChat>> _getBox() async {
    if (_box == null) {
      Hive.registerAdapter(HiveChatAdapter());
      _box = await Hive.openLazyBox<HiveChat>('chats.store');
    }

    return _box!;
  }

  @override
  Future<Chat?> getChat(int chatId) async {
    final box = await _getBox();

    if (box.containsKey(chatId)) {
      final chat = await box.get(chatId);

      return Chat(
        id: chat!.id,
        creationDate: chat.creationDate,
        model: chat.model,
      );
    }

    return null;
  }

  @override
  Future<Chat> addChat(Chat chat) async {
    final box = await _getBox();

    final hiveChat = HiveChat(
      creationDate: chat.creationDate,
      model: chat.model,
    );

    final id = await box.add(hiveChat);
    chat = chat.copyWith(id: id);
    await putChat(chat);

    return chat;
  }

  @override
  Future<void> putChat(Chat chat) async {
    final box = await _getBox();

    await box.put(
      chat.id,
      HiveChat(
        id: chat.id,
        creationDate: chat.creationDate,
        model: chat.model,
      ),
    );
  }

  @override
  Future<List<Chat>> getChats() async {
    final box = await _getBox();

    final list = <Chat>[];

    for (final key in box.keys) {
      final chat = await box.get(key);
      list.add(Chat(
        id: chat!.id,
        creationDate: chat.creationDate,
        model: chat.model,
      ));
    }

    return list;
  }

  @override
  Future<bool> deleteChat(int chatId) async {
    final box = await _getBox();

    if (box.containsKey(chatId)) {
      await box.delete(chatId);
      return true;
    }

    return false;
  }
}
