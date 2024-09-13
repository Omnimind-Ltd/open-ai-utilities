// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/database/ai_tools/chat/chat_db.dart';
import 'package:open_ai_utilities/data/database/ai_tools/messages/message_db.dart';
import 'package:open_ai_utilities/data/model/db_operation.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';
import 'package:open_ai_utilities/data/model/generative_ai/model_type.dart';

import 'open_ai_service.dart';

const _textModels = [
  'gpt-4o',
  'gpt-4-turbo',
  'gpt-4',
  'o1-preview',
  'o1-mini',
  'gpt-3.5-turbo',
];

const _imageModels = [
  'dall-e-3',
];

const _models = [
  ..._textModels,
  ..._imageModels,
];

class OpenAIServiceImpl extends OpenAIService {
  OpenAIServiceImpl(Ref ref)
      : _chatDB = ref.read(chatDBProvider),
        _messageDB = ref.read(messageDBProvider);

  final ChatDB _chatDB;
  final MessageDB _messageDB;

  final _chatsUpdatedStreamController =
      StreamController<DBOperation<Chat>>.broadcast();

  @override
  Stream<DBOperation<Chat>> get chatsUpdatedStream =>
      _chatsUpdatedStreamController.stream;

  final _messageUpdatedStreamController =
      StreamController<DBOperation<Message>>.broadcast();

  @override
  Stream<DBOperation<Message>> get messageUpdatedStream =>
      _messageUpdatedStreamController.stream;

  List<OpenAIModelModel>? _openAIModels;

  @override
  void init(String apiKey) {
    OpenAI.apiKey = apiKey;
  }

  @override
  FutureOr<List<OpenAIModelModel>?> getAllModels() async {
    _openAIModels ??= await OpenAI.instance.model.list();
    return _openAIModels;
  }

  @override
  List<String> getModels() {
    return _models;
  }

  @override
  Future<void> updateModel(int chatId, String model) async {
    var chat = await _chatDB.getChat(chatId);

    if (chat != null) {
      chat = chat.copyWith(model: model);
      _chatsUpdatedStreamController.add(DBOperation.update(chat));
      _chatDB.putChat(chat);
    }
  }

  @override
  ModelType getGenerationType(String model) {
    if (_imageModels.contains(model)) {
      return ModelType.image;
    }

    return ModelType.text;
  }

  @override
  Future<List<Message>> getMessages(int chatId) {
    return _messageDB.getMessages(chatId);
  }

  @override
  FutureOr<List<Chat>> getChats() {
    return _chatDB.getChats();
  }

  @override
  Future<Chat> newChat() async {
    final chat = await _chatDB.addChat(Chat(
      creationDate: DateTime.now(),
      model: _textModels.first,
    ));

    _chatsUpdatedStreamController.add(DBOperation.create(chat));

    return chat;
  }

  @override
  Future<void> clearChat(int chatId) async {
    final chat = await _chatDB.getChat(chatId);

    if (chat != null) {
      await _messageDB.deleteMessages(chatId);
    }
  }

  @override
  Future<void> deleteChat(int chatId) async {
    final chat = await _chatDB.getChat(chatId);

    if (chat != null) {
      await _chatDB.deleteChat(chatId);
      await _messageDB.deleteMessages(chatId);

      _chatsUpdatedStreamController.add(DBOperation.delete(chat));
    }
  }

  @override
  Future<void> sendMessage(
    int chatId,
    String text, {
    int numberChoices = 1,
    double? temperature,
    double? presencePenalty,
    double? frequencyPenalty,
  }) async {
    final chat = await _chatDB.getChat(chatId);

    final messages = (await _messageDB.getMessages(chatId))
        .where(
          (e) => e.type == MessageType.text,
        )
        .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: e.role,
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                      e.contentString)
                ]))
        .toList();

    messages.add(
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(text)],
      ),
    );

    final message = await _messageDB.addMessage(
      Message.text(text, chatId: chatId, role: OpenAIChatMessageRole.user),
    );

    _messageUpdatedStreamController.add(DBOperation.create(message));

    late StreamSubscription<OpenAIStreamChatCompletionModel> subscription;

    final activeMessageBuffers = <int, StringBuffer>{};
    final activeMessages = <int, Message>{};
    var finishCount = 0;

    subscription = OpenAI.instance.chat
        .createStream(
      model: chat!.model,
      messages: messages,
      temperature: temperature,
      n: numberChoices,
    )
        .listen((model) async {
      if (model.haveChoices) {
        for (final choice in model.choices) {
          activeMessageBuffers[choice.index] ??= StringBuffer();

          if (choice.delta.content != null) {
            for (final item in choice.delta.content!) {
              activeMessageBuffers[choice.index]!.write(item?.text);
            }
          }

          if (!activeMessages.containsKey(choice.index)) {
            activeMessages[choice.index] = Message.text(
              id: Random().nextInt(4294967296),
              activeMessageBuffers[choice.index].toString(),
              chatId: chat.id,
              role: OpenAIChatMessageRole.assistant,
            );

            _messageUpdatedStreamController
                .add(DBOperation.create(activeMessages[choice.index]!));
          } else {
            activeMessages[choice.index] =
                activeMessages[choice.index]!.copyWith(
              content: Uint16List.fromList(
                activeMessageBuffers[choice.index].toString().codeUnits,
              ),
            );

            _messageUpdatedStreamController
                .add(DBOperation.update(activeMessages[choice.index]!));
          }

          if (choice.finishReason != null) {
            _messageDB.addMessage(activeMessages[choice.index]!);
            activeMessages.remove(choice.index);
            activeMessageBuffers.remove(choice.index);
            finishCount++;
          }

          if (finishCount >= numberChoices) {
            subscription.cancel();
          }
        }
      }
    });
  }

  @override
  Future<void> generateImage(
    int chatId,
    String text, {
    bool highQuality = false,
    OpenAIImageStyle style = OpenAIImageStyle.vivid,
    OpenAIImageSize size = OpenAIImageSize.size1792Horizontal,
    int numberOfImages = 1,
  }) async {
    final chat = await _chatDB.getChat(chatId);

    if (chat == null) {
      return;
    }

    final message = await _messageDB.addMessage(
      Message.text(text, chatId: chatId, role: OpenAIChatMessageRole.user),
    );

    _messageUpdatedStreamController.add(DBOperation.create(message));

    OpenAIImageModel image = await OpenAI.instance.image.create(
      prompt: text,
      model: chat.model,
      quality: highQuality ? OpenAIImageQuality.hd : null,
      style: style,
      n: numberOfImages,
      size: size,
      responseFormat: OpenAIImageResponseFormat.b64Json,
    );

    for (int index = 0; index < image.data.length; index++) {
      final currentItem = image.data[index];

      Message? message;

      if (currentItem.haveUrl) {
        message = Message.imageUrl(
          currentItem.url!,
          chatId: chatId,
          role: OpenAIChatMessageRole.assistant,
        );
      } else if (currentItem.haveB64Json) {
        final imageBytes = base64.decode(currentItem.b64Json!);

        message = Message.image(
          Uint16List.view(imageBytes.buffer),
          chatId: chatId,
          role: OpenAIChatMessageRole.assistant,
        );
      }

      if (message != null) {
        _messageUpdatedStreamController.add(DBOperation.create(message));

        _messageDB.putMessage(
          message,
        );
      }
    }
  }

  @override
  Future<OpenAIChatCompletionModel> completion(
      List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    return OpenAI.instance.chat.create(
      model: _models.first,
      messages: messages,
    );
  }
}
