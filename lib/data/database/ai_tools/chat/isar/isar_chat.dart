// Copyright (c) 2024. Omnimind Ltd.

import 'package:isar/isar.dart';

part 'isar_chat.g.dart';

@Collection()
class IsarChat {
  Id id = Isar.autoIncrement;

  DateTime? creationDate;

  String? model;
}
