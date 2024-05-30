// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';

import 'isar/isar_message_db.dart'
    if (dart.library.js) 'hive/hive_message_db.dart';

final messageDBProvider = Provider<MessageDB>(
    (ref) => kIsWeb ? MessageDBImpl(ref) : MessageDBImpl(ref));

abstract class MessageDB {
  Future<Message> addMessage(Message message);

  Future<void> putMessage(Message message);

  Future<List<Message>> getMessages(int chatId);

  Future<void> deleteMessages(int chatId);
}
