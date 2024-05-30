// Copyright (c) 2024. Omnimind Ltd.

import 'package:hive_flutter/adapters.dart';

part 'hive_chat.g.dart';

@HiveType(typeId: 100)
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
