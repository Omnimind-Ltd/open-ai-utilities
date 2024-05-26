// Copyright (c) 2024. Omnimind Ltd.

import 'package:isar/isar.dart';

part 'isar_prompt.g.dart';

@Collection()
class IsarPrompt {
  Id id = Isar.autoIncrement;

  String? title;

  String? prompt;
}
