// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import '../prompt_db.dart';
import 'mem_prompt.dart';

class MemPromptDB extends PromptDB {
  MemPromptDB(Ref ref);

  final _prompts = <int, MemPrompt>{};

  var id = 1;

  @override
  Future<List<Prompt>> getPrompts() async {
    return _prompts.values
        .map((e) => Prompt(title: e.title, prompt: e.prompt))
        .toList();
  }

  @override
  Future<Prompt?> getPrompt(int promptId) async {
    if (_prompts.containsKey(promptId)) {
      return Prompt(
        id: _prompts[promptId]!.id,
        title: _prompts[promptId]!.title,
        prompt: _prompts[promptId]!.prompt,
      );
    }

    return null;
  }

  @override
  Future<Prompt> addPrompt(Prompt prompt) async {
    var id = this.id;
    this.id++;

    _prompts[id] = MemPrompt(
      id: prompt.id,
      title: prompt.title,
      prompt: prompt.prompt,
    );

    return prompt.copyWith(id: id);
  }

  @override
  Future<void> putPrompt(Prompt prompt) async {
    _prompts[prompt.id] = MemPrompt(
      id: prompt.id,
      title: prompt.title,
      prompt: prompt.prompt,
    );
  }

  @override
  Future<bool> deletePrompt(int promptId) async {
    if (_prompts.containsKey(promptId)) {
      _prompts.remove(promptId);
      return true;
    }

    return false;
  }
}
