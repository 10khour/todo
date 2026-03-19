import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

class Task {
  String id = "";
  bool finished = true;
  String text;
  int createdAt;  // 创建时间戳
  int? finishedAt;  // 完成时间戳

  Task({required this.text, this.finished = false}) : createdAt = DateTime.now().millisecondsSinceEpoch {
    var uuid = const Uuid();
    id = uuid.v4();
  }
  Task.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        finished = json['finished'],
        createdAt = json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
        finishedAt = json['finishedAt'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'finished': finished, 'text': text, 'createdAt': createdAt, if (finishedAt != null) 'finishedAt': finishedAt};
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

    t.finished = false;
    t.finishedAt = null;  // 清除完成时间
    await _addTask(t, todoPath);  // _addTask 现在会在写入前排序
  }

  finish(Task t) async {
    await _removeTask(t, todoPath);

    t.finished = true;
    t.finishedAt = DateTime.now().millisecondsSinceEpoch;  // 设置完成时间
    await _addTask(t, finishPath);  // _addTask 现在会在写入前排序
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
      List<Task> tasks = list.map((e) => Task.fromJson(e)).toList();

      // 排序：最后完成/最后创建的排在最上面
      tasks.sort((a, b) {
        // 如果是已完成任务列表，按完成时间降序
        if (path == finishPath) {
          if (b.finishedAt != null && a.finishedAt != null) {
            return b.finishedAt!.compareTo(a.finishedAt!);
          }
          // 如果没有完成时间，按创建时间降序
          return b.createdAt.compareTo(a.createdAt);
        }
        // 如果是未完成任务列表，按创建时间降序
        return b.createdAt.compareTo(a.createdAt);
      });

      return tasks;
    } catch (e) {
      return [];
    }
  }

  _removeTask(Task t, String path) async {
    List<Task> tasks = await _getTask(path);
    tasks.removeWhere((element) => element.id == t.id);
    File file = await getFile(path);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return await file.writeAsString(encoder.convert(tasks));
  }

  _addTask(Task t, String path) async {
    List<Task> tasks = await _getTask(path);
    tasks.add(t);

    // 写入前按正确顺序排序
    tasks.sort((a, b) {
      if (path == finishPath) {
        // 已完成任务按完成时间降序
        if (b.finishedAt != null && a.finishedAt != null) {
          return b.finishedAt!.compareTo(a.finishedAt!);
        }
        return b.createdAt.compareTo(a.createdAt);
      }
      // 未完成任务按创建时间降序
      return b.createdAt.compareTo(a.createdAt);
    });

    File file = await getFile(path);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return await file.writeAsString(encoder.convert(tasks));
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
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return await file.writeAsString(encoder.convert(tasks));
  }

  // ===== Weekly Grouping Methods =====

  /// 获取日期所在周的起始日（周一）
  DateTime _getWeekStart(DateTime date) {
    // 计算与周一的偏移量（周一为0，周日为6）
    final weekday = date.weekday; // 1-7，周一为1
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// 获取日期所在周的结束日（周日）
  DateTime _getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day + (7 - weekday));
  }

  /// 判断两个日期是否是同一周
  bool _isSameWeek(DateTime a, DateTime b) {
    return _getWeekStart(a) == _getWeekStart(b);
  }

  /// 生成周标签
  ///
  /// [weekStart]: 周起始日期（周一）
  /// [now]: 当前时间，用于计算相对标签
  String _getWeekLabel(DateTime weekStart, DateTime now) {
    final weekEnd = _getWeekEnd(weekStart);
    final currentWeekStart = _getWeekStart(now);
    final lastWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final twoWeeksAgoStart = currentWeekStart.subtract(const Duration(days: 14));

    // 格式化日期
    String formatDate(DateTime d) => "${d.month}月${d.day}日";
    String formatYearDate(DateTime d) => "${d.year}年${d.month}月${d.day}日";

    final dateRange = "${formatDate(weekStart)} - ${formatDate(weekEnd)}";

    if (weekStart == currentWeekStart) {
      return "本周 ($dateRange)";
    } else if (weekStart == lastWeekStart) {
      return "上周 ($dateRange)";
    } else if (weekStart == twoWeeksAgoStart) {
      return "两周前 ($dateRange)";
    } else {
      return "${formatYearDate(weekStart)} - ${formatDate(weekEnd)}";
    }
  }

  /// 将已完成任务按周分组
  ///
  /// 返回 LinkedHashMap: 周标签 -> 该周的任务列表（按周倒序，最新周在前）
  LinkedHashMap<String, List<Task>> groupTasksByWeek(List<Task> finishedTasks) {
    final now = DateTime.now();
    final Map<DateTime, List<Task>> groupedByWeekStart = {};

    for (final task in finishedTasks) {
      // 获取完成时间，优先使用 finishedAt，其次 createdAt
      final timestamp = task.finishedAt ?? task.createdAt;

      final finishedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      // 只保留年月日，去除时间部分
      final dateOnly = DateTime(finishedDate.year, finishedDate.month, finishedDate.day);
      final weekStart = _getWeekStart(dateOnly);

      groupedByWeekStart.putIfAbsent(weekStart, () => []);
      groupedByWeekStart[weekStart]!.add(task);
    }

    // 按周倒序排列
    final sortedWeeks = groupedByWeekStart.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final result = <String, List<Task>>{};

    for (final weekStart in sortedWeeks) {
      final label = _getWeekLabel(weekStart, now);
      final tasks = groupedByWeekStart[weekStart]!;
      // 同一周内按完成时间倒序
      tasks.sort((a, b) {
        final aTime = a.finishedAt ?? a.createdAt;
        final bTime = b.finishedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      result[label] = tasks;
    }

    return LinkedHashMap.from(result);
  }
}
