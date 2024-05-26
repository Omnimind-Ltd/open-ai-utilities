// Copyright (c) 2024. Omnimind Ltd.

class Prompt {
  Prompt({
    this.id = 0,
    required this.title,
    required this.prompt,
  });

  Prompt.create()
      : id = 0,
        title = '',
        prompt = '';

  final int id;

  final String title;

  final String prompt;

  Prompt copyWith({int? id, String? title, String? prompt}) {
    return Prompt(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
    );
  }
}
