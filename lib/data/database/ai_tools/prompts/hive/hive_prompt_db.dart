// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import '../prompt_db.dart';
import 'hive_prompt.dart';

class PromptDBImpl extends PromptDB {
  PromptDBImpl(Ref ref);

  LazyBox<HivePrompt>? _box;

  FutureOr<LazyBox<HivePrompt>> _getBox() async {
    if (_box == null) {
      Hive.registerAdapter(HivePromptAdapter());
      _box = await Hive.openLazyBox<HivePrompt>('prompts.store');
    }

    return _box!;
  }

  @override
  Future<List<Prompt>> getPrompts() async {
    final box = await _getBox();

    final list = <Prompt>[];

    for (final key in box.keys) {
      final prompt = await box.get(key);
      list.add(Prompt(
        id: prompt!.id,
        title: prompt.title,
        prompt: prompt.prompt,
      ));
    }

    return list;
  }

  @override
  Future<Prompt?> getPrompt(int promptId) async {
    final box = await _getBox();

    if (box.containsKey(promptId)) {
      final prompt = await box.get(promptId);

      return Prompt(
        id: prompt!.id,
        title: prompt.title,
        prompt: prompt.prompt,
      );
    }

    return null;
  }

  @override
  Future<Prompt> addPrompt(Prompt prompt) async {
    final box = await _getBox();

    final hivePrompt = HivePrompt(
      title: prompt.title,
      prompt: prompt.prompt,
    );

    final id = await box.add(hivePrompt);
    prompt = prompt.copyWith(id: id);
    await putPrompt(prompt);

    return prompt;
  }

  @override
  Future<void> putPrompt(Prompt prompt) async {
    final box = await _getBox();

    await box.put(
      prompt.id,
      HivePrompt(
        id: prompt.id,
        title: prompt.title,
        prompt: prompt.prompt,
      ),
    );
  }

  @override
  Future<bool> deletePrompt(int promptId) async {
    final box = await _getBox();

    if (box.containsKey(promptId)) {
      await box.delete(promptId);
      return true;
    }

    return false;
  }
}
