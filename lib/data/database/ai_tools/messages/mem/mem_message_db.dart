// Copyright (c) 2024. Omnimind Ltd.

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';

import '../message_db.dart';
import 'mem_message.dart';

class MemMessageDB extends MessageDB {
  MemMessageDB(Ref ref);

  final _messages = <int, List<MemMessage>>{};

  var id = 1;

  @override
  Future<void> deleteMessages(int chatId) async {
    _messages.remove(chatId);
  }

  @override
  Future<List<Message>> getMessages(int chatId) async {
    if (!_messages.containsKey(chatId)) {
      return <Message>[];
    }

    return _messages[chatId]!
        .map((e) => Message(
              chatId: e.chatId,
              role: OpenAIChatMessageRole.values
                  .singleWhere((element) => element.name == e.role),
              type: MessageType.values.singleWhere((t) => t.name == e.type),
              content: e.content,
            ))
        .toList(growable: false);
  }

  @override
  Future<Message> putMessage(Message message) async {
    var id = message.id;

    if (id == 0) {
      id = this.id;
      this.id++;
    }

    if (!_messages.containsKey(message.chatId)) {
      _messages[message.chatId] = <MemMessage>[];
    }

    final m = MemMessage(
      id: id,
      chatId: message.chatId,
      role: message.role.name,
      type: message.type.name,
      content: message.content,
    );

    if (message.id == 0) {
      _messages[message.chatId]!.add(m);

      return message.copyWith(id: id);
    } else {
      final index =
          _messages[message.chatId]!.indexWhere((e) => e.id == message.id);

      _messages[message.chatId]!.removeAt(index);
      _messages[message.chatId]!.insert(index, m);
    }

    return message;
  }
}
