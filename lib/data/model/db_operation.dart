// Copyright (c) 2024. Omnimind Ltd.

class DBOperation<T> {
  DBOperation.create(this.data) : type = DBOperationType.create;

  DBOperation.update(this.data) : type = DBOperationType.update;

  DBOperation.delete(this.data) : type = DBOperationType.delete;

  final DBOperationType type;

  final T data;
}

enum DBOperationType { create, update, delete }
