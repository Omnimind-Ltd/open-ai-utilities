// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';

import 'isar/isar_message_db.dart';

final messageDBProvider = Provider<MessageDB>((ref) => IsarMessageDB(ref));

abstract class MessageDB {
  Future<Message> putMessage(Message message);

  Future<List<Message>> getMessages(int chatId);

  Future<void> deleteMessages(int chatId);
}
