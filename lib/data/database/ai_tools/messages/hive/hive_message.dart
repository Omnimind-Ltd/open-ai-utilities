// Copyright (c) 2024. Omnimind Ltd.

import 'package:hive_flutter/adapters.dart';
import 'package:open_ai_utilities/data/database/hive/hive_db.dart';

part 'hive_message.g.dart';

@HiveType(typeId: hiveTypeIdMessage)
class HiveMessage {
  @HiveField(0)
  int id;

  @HiveField(1)
  int chatId;

  @HiveField(2)
  String role;

  @HiveField(3)
  String type;

  @HiveField(4)
  List<int> content;

  HiveMessage({
    this.id = 0,
    required this.chatId,
    required this.role,
    required this.type,
    required this.content,
  });
}
