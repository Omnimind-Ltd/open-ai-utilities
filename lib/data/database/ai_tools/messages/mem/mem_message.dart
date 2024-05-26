// Copyright (c) 2024. Omnimind Ltd.

import 'dart:typed_data';

class MemMessage {
  int id;

  final int chatId;

  final String role;

  final String type;

  final Uint16List content;

  MemMessage({
    this.id = 0,
    required this.chatId,
    required this.role,
    required this.type,
    required this.content,
  });
}
