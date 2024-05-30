// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/db_operation.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';

import 'generative_ai_service_impl.dart';

final generativeAIServiceProvider = Provider<GenerativeAIService>((ref) {
  return GenerativeAIServiceImpl(ref);
});

abstract class GenerativeAIService {
  Stream<DBOperation<Prompt>> get promptsUpdatedStream;

  Future<List<Prompt>> getPrompts();

  Future<void> addPrompt(Prompt prompt);

  Future<void> updatePrompt(Prompt prompt);

  Future<void> deletePrompt(int promptId);
}
