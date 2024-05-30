// Copyright (c) 2024. Omnimind Ltd.

import 'package:hive_flutter/adapters.dart';
import 'package:open_ai_utilities/data/database/hive/hive_db.dart';

part 'hive_prompt.g.dart';

@HiveType(typeId: hiveTypeIdPrompt)
class HivePrompt {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String prompt;

  HivePrompt({
    this.id = 0,
    required this.title,
    required this.prompt,
  });
}
