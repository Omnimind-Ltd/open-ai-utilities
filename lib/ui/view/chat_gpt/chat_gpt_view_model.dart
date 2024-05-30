// Copyright (c) 2024. Omnimind Ltd.

import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ai_utilities/data/model/db_operation.dart';
import 'package:open_ai_utilities/data/model/generative_ai/chat.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';
import 'package:open_ai_utilities/data/model/generative_ai/model_type.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';
import 'package:open_ai_utilities/data/services/file/file_service.dart';
import 'package:open_ai_utilities/data/services/generative_ai/generative_ai_service.dart';
import 'package:open_ai_utilities/data/services/open_ai/open_ai_service.dart';

import '../dialog/prompt_dialog/prompt_dialog.dart';

final viewModelProvider =
    ChangeNotifierProvider.autoDispose<ChatGPTViewModel>((ref) {
  return ChatGPTViewModel(ref);
});

class ChatGPTViewModel extends ChangeNotifier {
  ChatGPTViewModel(Ref ref)
      : _generativeAIService = ref.read(generativeAIServiceProvider),
        _openAIService = ref.read(openAIServiceProvider),
        _fileService = ref.read(fileServiceProvider) {
    loading = true;

    _promptsUpdatedSubscription =
        _generativeAIService.promptsUpdatedStream.listen(_onPromptUpdated);

    _chatsUpdatedSubscription =
        _openAIService.chatsUpdatedStream.listen(_onChatUpdated);

    _messageSubscription =
        _openAIService.messageUpdatedStream.listen(_onMessageUpdated);
  }

  final GenerativeAIService _generativeAIService;
  final OpenAIService _openAIService;
  final FileService _fileService;

  late final StreamSubscription<DBOperation<Prompt>>
      _promptsUpdatedSubscription;
  late final StreamSubscription<DBOperation<Chat>> _chatsUpdatedSubscription;
  late final StreamSubscription<DBOperation<Message>> _messageSubscription;

  final textEditingController = TextEditingController();

  final focusNode = FocusNode();

  final _chats = <Chat>[];

  final _messages = <Message>[];

  final _prompts = <Prompt>[];

  bool loading = false;

  BuildContext? context;

  int? _activeChatId;

  bool get chatActive => _activeChatId != null;

  List<Chat> get chats => _chats;

  Chat? get chat => _chats.singleWhereOrNull((e) => e.id == _activeChatId);

  String get chatTitle => chat?.formattedDate ?? 'Chat';

  List<Message> get messages => _messages;

  bool get haveMessages => messages.isNotEmpty;

  int get textFieldLines {
    final lines =
        textEditingController.text.characters.where((c) => c == '\n').length +
            1;

    return lines < 10 ? lines : 10;
  }

  bool get submitButtonEnabled => textEditingController.text.trim().isNotEmpty;

  List<Prompt> get promptItems => _prompts;

  List<String> get models => _openAIService.getModels();

  String get selectedModel => chat?.model ?? '';

  ModelType get modelType =>
      _openAIService.getGenerationType(chat?.model ?? '');

  int _numberChoices = 1;

  int get numChoices => _numberChoices;

  double _temperature = 1.0;

  double get temperature => _temperature;

  double _presencePenalty = 0.0;

  double get presencePenalty => _presencePenalty;

  double _frequencyPenalty = 0.0;

  double get frequencyPenalty => _frequencyPenalty;

  bool _highQualityImage = false;

  bool get highQualityImage => _highQualityImage;

  OpenAIImageStyle _imageStyle = OpenAIImageStyle.vivid;

  OpenAIImageStyle get imageStyle => _imageStyle;

  OpenAIImageSize _imageSize = OpenAIImageSize.size1024;

  OpenAIImageSize get imageSize => _imageSize;

  Future<void> init(BuildContext context) async {
    this.context = context;
    _chats.addAll(await _openAIService.getChats());

    if (_chats.isNotEmpty) {
      await _setActiveChatId(_chats.last.id);
    } else {
      await _openAIService.newChat();
    }

    _prompts.addAll(await _generativeAIService.getPrompts());

    setLoading(false);
  }

  void setLoading(bool loading) {
    if (this.loading != loading) {
      this.loading = loading;
      notifyListeners();
    }
  }

  Future<void> onNewChatPressed() async {
    await _openAIService.newChat();
  }

  Future<void> onNewPromptPressed() async {
    showDialog(
        context: context!,
        builder: (_) {
          final prompt = Prompt.create();
          return PromptDialog(prompt: prompt);
        }).then((prompt) {
      if (prompt != null) {
        _generativeAIService.addPrompt(prompt);
      }
    });
  }

  Future<void> onEditPromptPressed(Prompt prompt) async {
    showDialog(
        context: context!,
        builder: (_) {
          return PromptDialog(prompt: prompt);
        }).then((prompt) {
      if (prompt != null) {
        _generativeAIService.updatePrompt(prompt);
      }
    });
  }

  Future<void> onDeletePromptPressed(Prompt prompt) async {
    _generativeAIService.deletePrompt(prompt.id);
  }

  void onChatPressed(int chatId) {
    _setActiveChatId(chatId);
  }

  void onPromptPressed(Prompt prompt) {
    textEditingController.text = '${prompt.prompt}\n\n';

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 50), () {
      textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: textEditingController.text.length),
      );

      FocusScope.of(context!).requestFocus(focusNode);
    });
  }

  void onClearChatPressed() async {
    _messages.clear();
    notifyListeners();

    _openAIService.clearChat(_activeChatId!);
  }

  void onDeleteChatPressed({int? chatId}) {
    if (chatId != null) {
      _openAIService.deleteChat(chatId);
    } else {
      _openAIService.deleteChat(_activeChatId!);
    }
  }

  void onSubmitPressed() {
    final message = textEditingController.text.trim();

    switch (modelType) {
      case ModelType.text:
        _openAIService.sendMessage(
          _activeChatId!,
          message,
          numberChoices: _numberChoices,
          temperature: _temperature,
          presencePenalty: _presencePenalty,
          frequencyPenalty: _frequencyPenalty,
        );
        break;
      case ModelType.image:
        _openAIService.generateImage(
          _activeChatId!,
          message,
          highQuality: _highQualityImage,
          style: _imageStyle,
          size: _imageSize,
        );
        break;
      case ModelType.audio:
        break;
    }

    textEditingController.text = '';
    notifyListeners();
  }

  void onDownloadChatPressed() async {
    final buffer = StringBuffer();

    for (final message in _messages) {
      buffer.writeln('${message.role.name.toUpperCase()}:');
      buffer.writeln(message.content);
      buffer.writeln('---');
    }

    await _fileService.saveString(
        content: buffer.toString(), fileName: 'chat.txt');
  }

  void onDownloadImagePressed(Uint8List bytes) async {
    await _fileService.saveBytes(bytes: bytes, fileName: 'image.png');
  }

  void onNumChoicesUpdated(double value) {
    _numberChoices = value.round();
    notifyListeners();
  }

  void onTemperatureUpdated(double value) {
    _temperature = value;
    notifyListeners();
  }

  void onPresencePenaltyUpdated(double value) {
    _presencePenalty = value;
    notifyListeners();
  }

  void onFrequencyPenaltyUpdated(double value) {
    _frequencyPenalty = value;
    notifyListeners();
  }

  void onHighQualityImageUpdated(bool? value) {
    _highQualityImage = value ?? false;
    notifyListeners();
  }

  void onImageStyleUpdated(OpenAIImageStyle value) {
    _imageStyle = value;
    notifyListeners();
  }

  void onImageSizeUpdated(OpenAIImageSize value) {
    _imageSize = value;
    notifyListeners();
  }

  void onResetModelPressed() {
    _numberChoices = 1;
    _temperature = 1.0;
    _presencePenalty = 0.0;
    _frequencyPenalty = 0.0;
    _highQualityImage = false;
    _imageStyle = OpenAIImageStyle.vivid;
    _imageSize = OpenAIImageSize.size1024;

    notifyListeners();
  }

  void onTextUpdated(String? text) {
    notifyListeners();
  }

  void onEditingComplete() {
    final lines =
        textEditingController.text.characters.where((c) => c == '\n').length;

    if (lines == 0) {
      textEditingController.text = '${textEditingController.text}\n';
      notifyListeners();
    }
  }

  void onUpdateModel(String model) {
    _openAIService.updateModel(_activeChatId!, model);
  }

  Color getColor(OpenAIChatMessageRole role) {
    return switch (role) {
      OpenAIChatMessageRole.system => Colors.green,
      OpenAIChatMessageRole.user => Colors.white70,
      OpenAIChatMessageRole.assistant => Colors.blueGrey.shade100,
      OpenAIChatMessageRole.function => Colors.green,
      OpenAIChatMessageRole.tool => Colors.purple.shade200,
    };
  }

  void _onPromptUpdated(DBOperation<Prompt> operation) {
    switch (operation.type) {
      case DBOperationType.create:
        _prompts.add(operation.data);
        break;
      case DBOperationType.update:
        _prompts.removeWhere((e) => e.id == operation.data.id);
        _prompts.add(operation.data);
        break;
      case DBOperationType.delete:
        _prompts.removeWhere((e) => e.id == operation.data.id);
        break;
    }

    notifyListeners();
  }

  void _onChatUpdated(DBOperation<Chat> operation) {
    switch (operation.type) {
      case DBOperationType.create:
        _chats.add(operation.data);
        _setActiveChatId(operation.data.id);
        break;
      case DBOperationType.update:
        _chats.removeWhere((e) => e.id == operation.data.id);
        _chats.add(operation.data);
        _chats.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        notifyListeners();
        break;
      case DBOperationType.delete:
        _chats.removeWhere((e) => e.id == operation.data.id);
        _chats.sort((a, b) => a.creationDate.compareTo(b.creationDate));

        if (_chats.isEmpty) {
          _openAIService.newChat();
        } else {
          if (_activeChatId == operation.data.id) {
            _setActiveChatId(_chats.last.id);
          } else {
            notifyListeners();
          }
        }

        break;
    }
  }

  void _onMessageUpdated(DBOperation<Message> operation) {
    if (operation.type == DBOperationType.update) {
      messages.removeWhere((e) => e.id == operation.data.id);
      messages.add(operation.data);
    } else if (operation.type == DBOperationType.create) {
      messages.add(operation.data);
    } else if (operation.type == DBOperationType.delete) {
      messages.removeWhere((e) => e.id == operation.data.id);
    }

    notifyListeners();
  }

  Future<void> _setActiveChatId(int? id) async {
    _activeChatId = id;
    _messages.clear();

    if (_activeChatId != null) {
      final messages = await _openAIService.getMessages(_activeChatId!);
      this.messages.addAll(messages);
    }

    textEditingController.text = '';

    notifyListeners();
  }

  @override
  void dispose() {
    _promptsUpdatedSubscription.cancel();
    _chatsUpdatedSubscription.cancel();
    _messageSubscription.cancel();
    focusNode.dispose();

    super.dispose();
  }
}
