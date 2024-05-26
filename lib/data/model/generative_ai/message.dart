// Copyright (c) 2024. Omnimind Ltd.

import 'dart:typed_data';

import 'package:dart_openai/dart_openai.dart';

class Message {
  Message({
    this.id = 0,
    required this.chatId,
    required this.role,
    required this.type,
    required this.content,
  });

  Message.text(
    String content, {
    this.id = 0,
    required this.chatId,
    required this.role,
  })  : type = MessageType.text,
        content = Uint16List.fromList(content.codeUnits);

  Message.image(
    this.content, {
    this.id = 0,
    required this.chatId,
    required this.role,
  }) : type = MessageType.image;

  Message.imageUrl(
    String content, {
    this.id = 0,
    required this.chatId,
    required this.role,
  })  : type = MessageType.imageUrl,
        content = Uint16List.fromList(content.codeUnits);

  final int id;

  final int chatId;

  final OpenAIChatMessageRole role;

  final MessageType type;

  final Uint16List content;

  String get contentString => String.fromCharCodes(content);

  Uint8List get contentAsUint8List => Uint8List.view(content.buffer);

  Message copyWith({
    int? id,
    int? chatId,
    OpenAIChatMessageRole? role,
    MessageType? type,
    Uint16List? content,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      type: type ?? this.type,
      content: content ?? this.content,
    );
  }
}

enum MessageType {
  text,
  image,
  imageUrl,
  audio,
}
