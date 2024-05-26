// Copyright (c) 2024. Omnimind Ltd.

import 'package:intl/intl.dart';

class Chat {
  Chat({
    this.id = 0,
    required this.creationDate,
    required this.model,
  });

  final int id;

  final DateTime creationDate;

  final String model;

  String get formattedDate =>
      DateFormat('dd-MM-yyyy HH:mm').format(creationDate);

  Chat copyWith({
    int? id,
    DateTime? creationDate,
    String? model,
  }) {
    return Chat(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      model: model ?? this.model,
    );
  }
}
