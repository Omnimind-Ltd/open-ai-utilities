// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/db_operation.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';
import 'package:open_ai_utilities/data/model/generative_ai/model_type.dart';

import 'open_ai_service_impl.dart';

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIServiceImpl(ref);
});

abstract class OpenAIService {

  void init(String apiKey);

  Stream<DBOperation<Chat>> get chatsUpdatedStream;

  Stream<DBOperation<Message>> get messageUpdatedStream;

  FutureOr<List<OpenAIModelModel>?> getAllModels();

  List<String> getModels();

  Future<void> updateModel(int chatId, String model);

  ModelType getGenerationType(String model);

  FutureOr<List<Chat>> getChats();

  Future<List<Message>> getMessages(int chatId);

  Future<Chat> newChat();

  Future<void> sendMessage(
    int chatId,
    String text, {
    int numberChoices,
    double? temperature,
    double? presencePenalty,
    double? frequencyPenalty,
  });

  Future<void> generateImage(
    int chatId,
    String text, {
    bool highQuality = false,
    OpenAIImageStyle style = OpenAIImageStyle.vivid,
    OpenAIImageSize size = OpenAIImageSize.size1792Horizontal,
    int numberOfImages = 1,
  });

  Future<void> clearChat(int chatId);

  Future<void> deleteChat(int chatId);

  Future<OpenAIChatCompletionModel> completion(
      List<OpenAIChatCompletionChoiceMessageModel> messages);
}
