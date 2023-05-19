import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

class Task {
  String id = "";
  bool finished = true;
  String text;
  List<Task> subTasks = List.empty(growable: true);
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
  String path = "";
  TaskDriver({required this.path});

  getFile() async {
    File file = File(path);
    bool exists = file.existsSync();
    if (exists) {
      return file;
    }
    return await File(path).create(recursive: true);
  }

  Future<List<Task>> getTask() async {
    try {
      File file = await getFile();
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

  addTask(Task t) async {
    List<Task> tasks = await getTask();
    tasks.add(t);
    File file = await getFile();
    return await file.writeAsString(jsonEncode(tasks));
  }

  removeTask(Task t) async {
    List<Task> tasks = await getTask();
    tasks.removeWhere((element) => element.id == t.id);
    File file = await getFile();
    return await file.writeAsString(jsonEncode(tasks));
  }

  update(Task t) async {
    List<Task> tasks = await getTask();
    int index = 0;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].id == t.id) {
        index = i;
        break;
      }
    }
    tasks[index] = t;
    File file = await getFile();
    return await file.writeAsString(jsonEncode(tasks));
  }
}
