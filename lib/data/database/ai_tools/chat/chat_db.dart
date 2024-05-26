// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';

import 'isar/isar_chat_db.dart';

final chatDBProvider = Provider<ChatDB>((ref) => IsarChatDB(ref));

abstract class ChatDB {
  Future<Chat> putChat(Chat chat);

  Future<Chat?> getChat(int chatId);

  Future<List<Chat>> getChats();

  Future<bool> deleteChat(int chatId);
}
