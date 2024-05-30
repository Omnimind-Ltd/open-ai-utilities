// Copyright (c) 2024. Omnimind Ltd.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_highlighting/themes/dracula.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';
import 'package:open_ai_utilities/data/model/generative_ai/message.dart';
import 'package:open_ai_utilities/data/model/generative_ai/model_type.dart';
import 'package:open_ai_utilities/ui/widgets/button/interactive_button.dart';
import 'package:open_ai_utilities/ui/widgets/container/titled_widget.dart';
import 'package:open_ai_utilities/ui/widgets/loading_widget.dart';
import 'package:open_ai_utilities/ui/widgets/text/app_text.dart';

import 'chat_gpt_view_model.dart';

class ChatGPTWidget extends ConsumerStatefulWidget {
  const ChatGPTWidget({
    this.chatsVisible = true,
    this.modelVisible = true,
    this.promptsVisible = true,
    super.key,
  });

  final bool chatsVisible;
  final bool modelVisible;
  final bool promptsVisible;

  @override
  ConsumerState<ChatGPTWidget> createState() => _ChatGPTPageState();
}

class _ChatGPTPageState extends ConsumerState<ChatGPTWidget> {
  @override
  void initState() {
    super.initState();

    ref.read(viewModelProvider).init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.chatsVisible) const _ChatsWidget(),
        const Expanded(child: _MainWidget()),
        if (widget.modelVisible || widget.promptsVisible)
          SizedBox(
            width: 250,
            child: Column(
              children: [
                if (widget.modelVisible) const _ModelSettingsWidget(),
                if (widget.promptsVisible)
                  const Expanded(
                    child: _PromptsWidget(),
                  ),
              ],
            ),
          )
      ],
    );
  }
}

class _ChatsWidget extends ConsumerWidget {
  const _ChatsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider);

    return SizedBox(
      width: 250,
      child: TitledWidget(
        title: 'Chats',
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    final chat = viewModel.chats[index];

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InteractiveButton(
                          onTap: () {
                            viewModel.onChatPressed(chat.id);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 12),
                            title: AppText.titleMedium(chat.formattedDate),
                            trailing: PopupMenuButton<int>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (int item) {
                                viewModel.onDeleteChatPressed(chatId: chat.id);
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<int>>[
                                const PopupMenuItem<int>(
                                  value: 0,
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey.shade300,
                        )
                      ],
                    );
                  },
                  itemCount: viewModel.chats.length,
                ),
              ),
              SizedBox(
                height: 1,
                child: Container(
                  color: Colors.grey,
                ),
              ),
              InteractiveButton(
                onTap: viewModel.onNewChatPressed,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: Icon(Icons.add)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelSettingsWidget extends ConsumerWidget {
  const _ModelSettingsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider);

    return SizedBox(
      width: 250,
      child: TitledWidget(
        title: 'Model',
        contentMainAxisSize: MainAxisSize.min,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              initialValue: viewModel.selectedModel,
              onSelected: (String model) {
                viewModel.onUpdateModel(model);
              },
              itemBuilder: (BuildContext context) {
                return viewModel.models
                    .map((e) => PopupMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList();
              },
              child: Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade500),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3, right: 3),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 22,
                      ),
                    ),
                    AppText.titleMedium(
                      viewModel.selectedModel,
                    ),
                  ],
                ),
              ),
            ),
            if (viewModel.modelType == ModelType.text)
              const _TextModelSettingsWidget(),
            if (viewModel.modelType == ModelType.image)
              const _ImageModelSettingsWidget(),
            const Gutter(8),
            SizedBox(
              height: 1,
              child: Container(
                color: Colors.grey,
              ),
            ),
            InteractiveButton(
              onTap: viewModel.onResetModelPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Center(child: Text('Reset')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextModelSettingsWidget extends ConsumerWidget {
  const _TextModelSettingsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 22,
            top: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Tooltip(
                message:
                    'How many chat responses to\ngenerate for each input message.',
                child: Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.info_outline,
                    size: 17,
                  ),
                ),
              ),
              AppText.titleMedium(
                'Responses: ${viewModel.numChoices.toString()}',
              ),
            ],
          ),
        ),
        Slider(
          value: viewModel.numChoices.toDouble(),
          onChanged: viewModel.onNumChoicesUpdated,
          min: 1,
          max: 5,
          divisions: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 22,
            top: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Tooltip(
                message:
                    'Higher values like 0.8 will make the output more random. Lower\nvalues like 0.2 will make it more focused and deterministic.',
                child: Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.info_outline,
                    size: 17,
                  ),
                ),
              ),
              AppText.titleMedium(
                'Temperature: ${viewModel.temperature.toStringAsFixed(1)}',
              ),
            ],
          ),
        ),
        Slider(
          value: viewModel.temperature,
          onChanged: viewModel.onTemperatureUpdated,
          min: 0.0,
          max: 2.0,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 22,
            top: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Tooltip(
                message:
                    'Positive values penalize new tokens based on whether they appear in the\ntext so far, increasing the model\'s likelihood to talk about new topics.',
                child: Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.info_outline,
                    size: 17,
                  ),
                ),
              ),
              AppText.titleMedium(
                'Presence penalty: ${viewModel.presencePenalty.toStringAsFixed(1)}',
              ),
            ],
          ),
        ),
        Slider(
          value: viewModel.presencePenalty,
          onChanged: viewModel.onPresencePenaltyUpdated,
          min: -2.0,
          max: 2.0,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 22,
            top: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Tooltip(
                message:
                    'Positive values penalize new tokens based on their existing frequency in the\ntext so far, decreasing the model\'s likelihood to repeat the same line verbatim.',
                child: Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.info_outline,
                    size: 17,
                  ),
                ),
              ),
              AppText.titleMedium(
                'Frequency penalty: ${viewModel.frequencyPenalty.toStringAsFixed(1)}',
              ),
            ],
          ),
        ),
        Slider(
          value: viewModel.frequencyPenalty,
          onChanged: viewModel.onFrequencyPenaltyUpdated,
          min: -2.0,
          max: 2.0,
        ),
      ],
    );
  }
}

class _ImageModelSettingsWidget extends ConsumerWidget {
  const _ImageModelSettingsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 22,
            top: 4,
            right: 16,
          ),
          child: AppText.titleMedium(
            'Image Quality',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: viewModel.highQualityImage,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.onHighQualityImageUpdated(false);
                        }
                      },
                    ),
                    const Tooltip(
                      message: 'Default quality',
                      child: AppText.bodyMedium(
                        'Standard',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: viewModel.highQualityImage,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.onHighQualityImageUpdated(true);
                        }
                      },
                    ),
                    const Tooltip(
                      message:
                          'Creates images with finer details and\ngreater consistency across the image.',
                      child: AppText.bodyMedium(
                        'HD',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 22,
            top: 14,
          ),
          child: AppText.titleMedium(
            'Style',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<OpenAIImageStyle>(
                      value: OpenAIImageStyle.vivid,
                      groupValue: viewModel.imageStyle,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.onImageStyleUpdated(value);
                        }
                      },
                    ),
                    const Tooltip(
                      message:
                          'Vivid causes the model to lean towards\ngenerating hyper-real and dramatic images.',
                      child: AppText.bodyMedium(
                        'Vivid',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<OpenAIImageStyle>(
                      value: OpenAIImageStyle.natural,
                      groupValue: viewModel.imageStyle,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.onImageStyleUpdated(value);
                        }
                      },
                    ),
                    const Tooltip(
                      message:
                          'Natural causes the model to produce more\nnatural, less hyper-real looking images.',
                      child: AppText.bodyMedium(
                        'Natural',
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 22,
            top: 14,
          ),
          child: AppText.titleMedium(
            'Size',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<OpenAIImageSize>(
                      value: OpenAIImageSize.size1024,
                      groupValue: viewModel.imageSize,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.onImageSizeUpdated(value);
                        }
                      },
                    ),
                    const AppText.bodyMedium(
                      '1024x1024',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<OpenAIImageSize>(
                      value: OpenAIImageSize.size1792Horizontal,
                      groupValue: viewModel.imageSize,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.onImageSizeUpdated(value);
                        }
                      },
                    ),
                    const AppText.bodyMedium(
                      '1792x1024',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<OpenAIImageSize>(
                value: OpenAIImageSize.size1792Vertical,
                groupValue: viewModel.imageSize,
                onChanged: (value) {
                  if (value != null) {
                    viewModel.onImageSizeUpdated(value);
                  }
                },
              ),
              const AppText.bodyMedium(
                '1024x1792',
              ),
            ],
          ),
        ),
        const Gutter(8),
      ],
    );
  }
}

class _PromptsWidget extends ConsumerWidget {
  const _PromptsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider);

    return SizedBox(
      width: 250,
      child: TitledWidget(
        title: 'Prompts',
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.promptItems.length,
                  itemBuilder: (_, index) {
                    final prompt = viewModel.promptItems[index];

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InteractiveButton(
                          onTap: () {
                            viewModel.onPromptPressed(prompt);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 12),
                            title: Text(prompt.title),
                            trailing: PopupMenuButton<int>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (int item) {
                                if (item == 0) {
                                  viewModel.onEditPromptPressed(prompt);
                                } else if (item == 1) {
                                  viewModel.onDeletePromptPressed(prompt);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<int>>[
                                const PopupMenuItem<int>(
                                  value: 0,
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  ),
                                ),
                                const PopupMenuItem<int>(
                                  value: 1,
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey.shade300,
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: 1,
                child: Container(
                  color: Colors.grey,
                ),
              ),
              InteractiveButton(
                onTap: viewModel.onNewPromptPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Center(child: Icon(Icons.add)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainWidget extends ConsumerWidget {
  const _MainWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(viewModelProvider);

    late Widget widget;

    if (!viewModel.chatActive) {
      widget = const Center(
        child: LoadingWidget(),
      );
    } else {
      widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: viewModel.messages.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return const Gutter(4);
              }

              final item = viewModel.messages[index - 1];

              late Widget widget;

              switch (item.type) {
                case MessageType.text:
                  widget = _HighlightedTextWidget(text: item.contentString);
                  break;
                case MessageType.image:
                  widget = Stack(children: [
                    Image.memory(item.contentAsUint8List),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.file_download_rounded),
                        onPressed: () {
                          viewModel
                              .onDownloadImagePressed(item.contentAsUint8List);
                        },
                      ),
                    ),
                  ]);
                  break;
                case MessageType.imageUrl:
                  widget = CachedNetworkImage(
                    imageUrl: item.contentString,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  );

                  break;
                case MessageType.audio:
                  widget = Container();
                  break;
              }

              return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.0,
                      ),
                      color: viewModel.getColor(item.role),
                    ),
                    child: widget,
                  ));
            },
          )),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 6.0,
              left: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: viewModel.focusNode,
                    autofocus: true,
                    key: ValueKey(viewModel.textFieldLines),
                    controller: viewModel.textEditingController,
                    onChanged: viewModel.onTextUpdated,
                    decoration: const InputDecoration(
                        hintText: 'Enter prompt',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        )),
                    maxLines: viewModel.textFieldLines,
                    onEditingComplete: viewModel.onEditingComplete,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                IconButton(
                  onPressed: viewModel.submitButtonEnabled
                      ? viewModel.onSubmitPressed
                      : null,
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 32,
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }

    return TitledWidget(
      title: viewModel.chatTitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: viewModel.onDownloadChatPressed,
            child: const Icon(
              Icons.download_for_offline,
              color: Colors.white,
            ),
          ),
          const Gutter(8),
          GestureDetector(
            onTap: viewModel.onClearChatPressed,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ],
      ),
      child: Expanded(child: widget),
    );
  }
}

const _languageMap = {
  '': 'plaintext',
  'carbon': 'c++',
  'html': 'xml',
  'js': 'javascript',
  'jsx': 'javascript',
  'sh': 'bash',
  'svelte': 'xml',
  'tsx': 'javascript',
  'groovy': 'plaintext',
  'toml': 'plaintext',
};

class _HighlightedTextWidget extends StatelessWidget {
  _HighlightedTextWidget({required String text}) : _text = text;

  final String _text;

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    const codeDelimiter = '```';
    const newline = '\n';

    int startIndex = 0;
    int endIndex;

    while (startIndex < _text.length) {
      endIndex = _text.indexOf(codeDelimiter, startIndex);

      if (endIndex == -1) {
        children.add(SyntaxHighlightingText(text: _text.substring(startIndex)));
        break;
      } else {
        if (startIndex != endIndex) {
          children.add(SyntaxHighlightingText(
              text: _text.substring(startIndex, endIndex - 1)));
        }

        startIndex = endIndex + codeDelimiter.length;
        endIndex = _text.indexOf(newline, startIndex);
        String language = 'plaintext';

        if (endIndex != -1) {
          // Extract language identifier
          language = _text.substring(startIndex, endIndex).trim();
          startIndex =
              endIndex + newline.length; // move to the start of the code block
        }

        if (_languageMap.containsKey(language)) {
          language = _languageMap[language]!;
        }

        endIndex = _text.indexOf(codeDelimiter, startIndex);

        if (endIndex == -1) {
          children.add(SelectableRegion(
            selectionControls: materialTextSelectionControls,
            focusNode: _focusNode,
            child: HighlightView(
              _text.substring(startIndex),
              languageId: language,
              theme: draculaTheme,
              padding: const EdgeInsets.all(12),
              selectable: true,
            ),
          ));
          break;
        } else {
          children.add(SelectableRegion(
            selectionControls: materialTextSelectionControls,
            focusNode: _focusNode,
            child: HighlightView(
              _text.substring(startIndex, endIndex - 1),
              languageId: language,
              theme: draculaTheme,
              padding: const EdgeInsets.all(12),
              selectable: true,
            ),
          ));
          startIndex = endIndex + codeDelimiter.length;
        }
      }
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class SyntaxHighlightingText extends StatelessWidget {
  final String text;

  const SyntaxHighlightingText({super.key, required this.text});

  List<TextSpan> parseText(String text) {
    const textStyle = TextStyle(color: Colors.black, fontSize: 15.0);
    final codeStyle = textStyle.copyWith(
      backgroundColor: const Color(0xFF282a36),
      color: Colors.green.shade300,
    );

    List<TextSpan> spans = [];
    final RegExp regex = RegExp(r"`([^`]+)`");
    int lastMatchEnd = 0;

    for (final Match match in regex.allMatches(text)) {
      final String preText = text.substring(lastMatchEnd, match.start);
      if (preText.isNotEmpty) {
        spans.add(TextSpan(text: preText, style: textStyle));
      }

      final String codeText = match.group(1)!;
      spans.add(TextSpan(text: ' $codeText ', style: codeStyle));

      lastMatchEnd = match.end;
    }

    final String remainingText = text.substring(lastMatchEnd);
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(text: remainingText, style: textStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      selectionRegistrar: SelectionContainer.maybeOf(context),
      selectionColor: const Color(0xAF6694e8),
      text: TextSpan(
        children: parseText(text),
      ),
    );
  }
}
