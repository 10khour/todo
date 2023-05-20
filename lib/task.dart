import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

class Task {
  String id = "";
  bool finished = true;
  String text;
  Task({required this.text, this.finished = false}) {
    var uuid = const Uuid();
    id = uuid.v4();
  }
  Task.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        finished = json['finished'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'finished': finished, 'text': text};
}

class TaskDriver {
  String todoPath = "";
  String finishPath = "";
  TaskDriver({required this.todoPath, required this.finishPath});

  getFile(String path) async {
    File file = File(path);
    bool exists = file.existsSync();
    if (exists) {
      return file;
    }
    return await File(path).create(recursive: true);
  }

  unfinish(Task t) async {
    await _removeTask(t, finishPath);
    File file = await getFile(todoPath);

    var list = await getTask(finished: false);
    list.add(t);
    await file.writeAsString(jsonEncode(list));
  }

  finish(Task t) async {
    await _removeTask(t, todoPath);
    File file = await getFile(finishPath);

    var list = await getTask(finished: true);
    list.add(t);
    await file.writeAsString(jsonEncode(list));
  }

  update(Task t) async {
    if (t.finished) {
      return await _update(t, finishPath);
    }
    await _update(t, todoPath);
  }

  Future<List<Task>> getTask({bool finished = false}) async {
    if (finished) {
      return await _getTask(finishPath);
    }
    return await _getTask(todoPath);
  }

  addTask(Task t) async {
    if (t.finished) {
      return _addTask(t, finishPath);
    }
    await _addTask(t, todoPath);
  }

  removeTask(Task t) async {
    if (t.finished) {
      return await _removeTask(t, finishPath);
    }
    await _removeTask(t, todoPath);
  }

  Future<List<Task>> _getTask(String path) async {
    try {
      File file = await getFile(path);
      String contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      List<dynamic> list = jsonDecode(contents);
      return list.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  _removeTask(Task t, String path) async {
    List<Task> tasks = await _getTask(path);
    tasks.removeWhere((element) => element.id == t.id);
    File file = await getFile(path);
    return await file.writeAsString(jsonEncode(tasks));
  }

  _addTask(Task t, String path) async {
    List<Task> tasks = await _getTask(path);
    tasks.add(t);
    File file = await getFile(path);
    return await file.writeAsString(jsonEncode(tasks));
  }

  _update(Task t, String path) async {
    List<Task> tasks = await _getTask(path);
    int index = -1;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].id == t.id) {
        index = i;
        break;
      }
    }
    if (index < 0) {
      return;
    }
    tasks[index] = t;
    File file = await getFile(path);
    return await file.writeAsString(jsonEncode(tasks));
  }
}
