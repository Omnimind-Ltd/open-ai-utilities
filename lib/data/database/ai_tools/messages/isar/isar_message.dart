// Copyright (c) 2024. Omnimind Ltd.

import 'package:isar/isar.dart';

part 'isar_message.g.dart';

@Collection()
class IsarMessage {
  Id id = Isar.autoIncrement;

  int? chatId;

  String? role;

  String? type;

  List<int>? content;
}
