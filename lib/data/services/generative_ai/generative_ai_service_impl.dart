// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/database/ai_tools/prompts/prompt_db.dart';
import 'package:open_ai_utilities/data/model/db_operation.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import 'generative_ai_service.dart';

class GenerativeAIServiceImpl extends GenerativeAIService {
  GenerativeAIServiceImpl(Ref ref) : _promptDB = ref.read(promptDBProvider);

  final PromptDB _promptDB;

  final _promptsUpdatedStreamController =
      StreamController<DBOperation<Prompt>>.broadcast();

  @override
  Stream<DBOperation<Prompt>> get promptsUpdatedStream =>
      _promptsUpdatedStreamController.stream;

  @override
  Future<List<Prompt>> getPrompts() async {
    return _promptDB.getPrompts();
  }

  @override
  Future<void> addPrompt(Prompt prompt) async {
    prompt = await _promptDB.addPrompt(prompt);
    _promptsUpdatedStreamController.add(DBOperation.create(prompt));
  }

  @override
  Future<void> updatePrompt(Prompt prompt) async {
    await _promptDB.putPrompt(prompt);
    _promptsUpdatedStreamController.add(DBOperation.update(prompt));
  }

  @override
  Future<void> deletePrompt(int promptId) async {
    final prompt = await _promptDB.getPrompt(promptId);

    if (prompt != null) {
      await _promptDB.deletePrompt(promptId);
      _promptsUpdatedStreamController.add(DBOperation.delete(prompt));
    }
  }
}
