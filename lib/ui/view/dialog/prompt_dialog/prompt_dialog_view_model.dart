// Copyright (c) 2024. Omnimind Ltd.

import 'package:open_ai_utilities/data/model/generative_ai/prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final viewModelProvider =
    ChangeNotifierProvider.autoDispose<PromptDialogViewModel>((ref) {
  return PromptDialogViewModel();
});

class PromptDialogViewModel extends ChangeNotifier {
  PromptDialogViewModel();

  late final BuildContext context;

  final titleTextEditingController = TextEditingController();

  final promptTextEditingController = TextEditingController();

  late final Prompt _prompt;

  String get title => _prompt.id == 0 ? 'New prompt' : 'Edit prompt';

  bool get canSave =>
      titleTextEditingController.text.trim().isNotEmpty &&
      promptTextEditingController.text.trim().isNotEmpty;

  void init(
    BuildContext context,
    Prompt prompt,
  ) {
    this.context = context;
    _prompt = prompt;

    titleTextEditingController.text = _prompt.title;
    promptTextEditingController.text = _prompt.prompt;
  }

  void onCancelPressed() {
    Navigator.of(context).pop();
  }

  void onSavePressed() {
    final prompt = _prompt.copyWith(
        title: titleTextEditingController.text.trim(),
        prompt: promptTextEditingController.text.trim());

    Navigator.of(context).pop(prompt);
  }

  void onTitleUpdated(String text) {
    notifyListeners();
  }

  void onPromptUpdated(String text) {
    notifyListeners();
  }
}
