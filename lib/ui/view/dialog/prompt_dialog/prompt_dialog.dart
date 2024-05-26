// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';
import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';
import 'package:open_ai_utilities/ui/widgets/text/app_text.dart';

import 'prompt_dialog_view_model.dart';

class PromptDialog extends ConsumerStatefulWidget {
  const PromptDialog({
    required Prompt prompt,
    super.key,
  }) : _prompt = prompt;

  final Prompt _prompt;

  @override
  ConsumerState<PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends ConsumerState<PromptDialog> {
  @override
  void initState() {
    super.initState();

    ref.read(viewModelProvider).init(context, widget._prompt);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(viewModelProvider);

    return AlertDialog(
      title: AppText.titleLarge(viewModel.title),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: <Widget>[
              TextField(
                controller: viewModel.titleTextEditingController,
                onChanged: viewModel.onTitleUpdated,
                decoration: const InputDecoration(hintText: 'Enter title'),
              ),
              const Gutter(12),
              TextField(
                controller: viewModel.promptTextEditingController,
                onChanged: viewModel.onPromptUpdated,
                decoration: const InputDecoration(hintText: 'Enter prompt'),
                minLines: 3,
                maxLines: 10,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: viewModel.onCancelPressed,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: viewModel.canSave ? viewModel.onSavePressed : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
