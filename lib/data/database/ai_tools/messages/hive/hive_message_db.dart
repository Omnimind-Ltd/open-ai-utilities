// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';
import 'dart:typed_data';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:open_ai_utilities/data/database/hive/hive_db.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';

import '../message_db.dart';
import 'hive_message.dart';

class MessageDBImpl extends MessageDB {
  MessageDBImpl(Ref ref);

  final _boxes = <int, LazyBox<HiveMessage>>{};

  FutureOr<LazyBox<HiveMessage>> _getBox(int chatId) async {
    if (!_boxes.containsKey(chatId)) {
      if (!Hive.isAdapterRegistered(hiveTypeIdMessage)) {
        Hive.registerAdapter(HiveMessageAdapter());
      }

      _boxes[chatId] =
          await Hive.openLazyBox<HiveMessage>('messages_$chatId.store');
    }

    return _boxes[chatId]!;
  }

  var id = 1;

  @override
  Future<void> deleteMessages(int chatId) async {
    final box = await _getBox(chatId);
    await box.deleteFromDisk();
  }

  @override
  Future<List<Message>> getMessages(int chatId) async {
    final box = await _getBox(chatId);

    final messages = <Message>[];

    for (final key in box.keys) {
      final message = await box.get(key);
      messages.add(Message(
        id: message!.id,
        chatId: message.chatId,
        role: OpenAIChatMessageRole.values
            .singleWhere((e) => e.name == message.role),
        type: MessageType.values.singleWhere((t) => t.name == message.type),
        content: Uint16List.fromList(message.content),
      ));
    }

    return messages;
  }

  @override
  Future<Message> addMessage(Message message) async {
    final box = await _getBox(message.chatId);

    final hiveMessage = HiveMessage(
      chatId: message.chatId,
      role: message.role.name,
      type: message.type.name,
      content: message.content,
    );

    final id = await box.add(hiveMessage);
    message = message.copyWith(id: id);
    await putMessage(message);

    return message;
  }

  @override
  Future<void> putMessage(Message message) async {
    final box = await _getBox(message.chatId);

    await box.put(
        message.id,
        HiveMessage(
          id: id,
          chatId: message.chatId,
          role: message.role.name,
          type: message.type.name,
          content: message.content,
        ));
  }
}
