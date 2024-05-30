// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import 'isar/isar_prompt_db.dart'
    if (dart.library.js) 'hive/hive_prompt_db.dart';

final promptDBProvider =
    Provider<PromptDB>((ref) => kIsWeb ? PromptDBImpl(ref) : PromptDBImpl(ref));

abstract class PromptDB {
  Future<List<Prompt>> getPrompts();

  Future<Prompt?> getPrompt(int promptId);

  Future<Prompt> addPrompt(Prompt prompt);

  Future<void> putPrompt(Prompt prompt);

  Future<bool> deletePrompt(int promptId);
}
