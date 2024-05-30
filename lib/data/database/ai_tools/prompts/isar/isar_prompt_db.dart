// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:open_ai_utilities/data/database/ai_tools/prompts/isar/isar_prompt.dart';
import 'package:open_ai_utilities/data/database/isar/isar_db.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import '../prompt_db.dart';

class PromptDBImpl extends PromptDB {
  PromptDBImpl(Ref ref) : _isarService = ref.read(isarServiceProvider);

  final IsarService _isarService;

  @override
  Future<List<Prompt>> getPrompts() async {
    final isar = await _isarService.get();

    final prompts = await isar.isarPrompts.where().findAll();

    return prompts
        .map((e) => Prompt(id: e.id, title: e.title!, prompt: e.prompt!))
        .toList();
  }

  @override
  Future<Prompt?> getPrompt(int promptId) async {
    final isar = await _isarService.get();

    final prompt = await isar.isarPrompts.get(promptId);

    if (prompt != null) {
      return Prompt(
          id: prompt.id, title: prompt.title!, prompt: prompt.prompt!);
    }

    return null;
  }

  @override
  Future<Prompt> addPrompt(Prompt prompt) async {
    final isar = await _isarService.get();

    final p = IsarPrompt()
      ..title = prompt.title
      ..prompt = prompt.prompt;

    final id = await isar.writeTxn(() async {
      return await isar.isarPrompts.put(p);
    });

    return prompt.copyWith(id: id);
  }

  @override
  Future<void> putPrompt(Prompt prompt) async {
    final isar = await _isarService.get();

    final p = IsarPrompt()
      ..id = prompt.id
      ..title = prompt.title
      ..prompt = prompt.prompt;

    await isar.writeTxn(() async {
      await isar.isarPrompts.put(p);
    });
  }

  @override
  Future<bool> deletePrompt(int promptId) async {
    final isar = await _isarService.get();

    return await isar.writeTxn(() async {
      return isar.isarPrompts.delete(promptId);
    });
  }
}
