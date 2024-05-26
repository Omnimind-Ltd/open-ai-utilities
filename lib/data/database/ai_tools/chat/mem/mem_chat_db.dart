// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';

import '../chat_db.dart';
import 'mem_chat.dart';

class MemChatDB implements ChatDB {
  MemChatDB(Ref ref);

  final _chats = <int, MemChat>{};

  var id = 1;

  @override
  Future<Chat?> getChat(int chatId) async {
    if (_chats.containsKey(chatId)) {
      return Chat(
        id: _chats[chatId]!.id,
        creationDate: _chats[chatId]!.creationDate,
        model: _chats[chatId]!.model,
      );
    }

    return null;
  }

  @override
  Future<Chat> putChat(Chat chat) async {
    var id = chat.id;

    if (id == 0) {
      id = this.id;
      this.id++;
    }

    _chats[id] = MemChat(
      id: id,
      creationDate: chat.creationDate,
      model: chat.model,
    );

    return chat.copyWith(id: id);
  }

  @override
  Future<List<Chat>> getChats() async {
    return _chats.values
        .map((e) => Chat(
              id: e.id,
              creationDate: e.creationDate,
              model: e.model,
            ))
        .toList();
  }

  @override
  Future<bool> deleteChat(int chatId) async {
    if (_chats.containsKey(chatId)) {
      _chats.remove(chatId);
      return true;
    } else {
      return false;
    }
  }
}
