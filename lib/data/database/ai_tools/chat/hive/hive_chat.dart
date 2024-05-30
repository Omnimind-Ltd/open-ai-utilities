// Copyright (c) 2024. Omnimind Ltd.

import 'package:hive_flutter/adapters.dart';
import 'package:open_ai_utilities/data/database/hive/hive_db.dart';

part 'hive_chat.g.dart';

@HiveType(typeId: hiveTypeIdChat)
class HiveChat {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime creationDate;

  @HiveField(2)
  String model;

  HiveChat({
    this.id = 0,
    required this.creationDate,
    required this.model,
  });
}
