// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import 'isar/isar_prompt_db.dart';

final promptDBProvider = Provider<PromptDB>((ref) => IsarPromptDB(ref));

abstract class PromptDB {
  Future<List<Prompt>> getPrompts();

  Future<Prompt?> getPrompt(int promptId);

  Future<Prompt> putPrompt(Prompt prompt);

  Future<bool> deletePrompt(int promptId);
}
