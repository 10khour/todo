# 已完成任务按周分组功能实施计划

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将已完成的任务按自然周分组展示，本周默认展开，历史周默认折叠。

**Architecture:** 在 TaskDriver 中添加任务分组逻辑，使用 LinkedHashMap 保持周顺序；UI 层创建可折叠的周分组列表，使用 Map 维护各周展开状态。

**Tech Stack:** Flutter, Dart

---

## 文件结构

| 文件 | 职责 |
|------|------|
| `lib/task.dart` | 添加 `groupTasksByWeek()` 方法和周标签生成辅助方法 |
| `lib/week_group_header.dart` | 新增周分组标题组件，显示周标签、任务数和展开/折叠按钮 |
| `lib/todo_list.dart` | 修改已完成任务渲染逻辑，使用分组数据 |

---

## Task 1: 添加周分组逻辑到 TaskDriver

**Files:**
- Modify: `lib/task.dart`

### Step 1: 添加周计算辅助方法

```dart
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
```

### Step 2: 添加周标签生成方法

```dart
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
```

### Step 3: 添加任务分组方法

```dart
import 'dart:collection';

/// 将已完成任务按周分组
///
/// 返回 LinkedHashMap: 周标签 -> 该周的任务列表（按周倒序，最新周在前）
LinkedHashMap<String, List<Task>> groupTasksByWeek(List<Task> finishedTasks) {
  final now = DateTime.now();
  final Map<DateTime, List<Task>> groupedByWeekStart = {};
  final List<Task> unknownTimeTasks = [];

  for (final task in finishedTasks) {
    // 获取完成时间，优先使用 finishedAt，其次 createdAt
    final timestamp = task.finishedAt ?? task.createdAt;
    if (timestamp == null) {
      unknownTimeTasks.add(task);
      continue;
    }

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

  final result = LinkedHashMap<String, List<Task>>();

  for (final weekStart in sortedWeeks) {
    final label = _getWeekLabel(weekStart, now);
    final tasks = groupedByWeekStart[weekStart]!;
    // 同一周内按完成时间倒序
    tasks.sort((a, b) {
      final aTime = b.finishedAt ?? b.createdAt;
      final bTime = a.finishedAt ?? a.createdAt;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    result[label] = tasks;
  }

  // 添加未知时间分组（如果有）
  if (unknownTimeTasks.isNotEmpty) {
    result["未知时间"] = unknownTimeTasks;
  }

  return result;
}
```

### Step 4: 验证代码无语法错误

Run: `flutter analyze lib/task.dart`
Expected: No errors

### Step 5: Commit

```bash
git add lib/task.dart
git commit -m "feat: add weekly task grouping methods to TaskDriver

- Add _getWeekStart and _getWeekEnd helpers for ISO week calculation
- Add _getWeekLabel for generating relative week labels
- Add groupTasksByWeek to group finished tasks by week with ordering

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 创建周分组标题组件

**Files:**
- Create: `lib/week_group_header.dart`

### Step 1: 创建组件文件

```dart
import 'package:flutter/material.dart';

class WeekGroupHeader extends StatelessWidget {
  final String label;
  final int taskCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const WeekGroupHeader({
    super.key,
    required this.label,
    required this.taskCount,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 展开/折叠图标
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            // 周标签
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            // 任务数量
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$taskCount',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 2: 验证组件无语法错误

Run: `flutter analyze lib/week_group_header.dart`
Expected: No errors

### Step 3: Commit

```bash
git add lib/week_group_header.dart
git commit -m "feat: add WeekGroupHeader component for weekly task grouping

- Collapsible header with rotation animation
- Shows week label and task count badge
- Follows existing UI styling patterns

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 修改 TodoList 使用分组数据

**Files:**
- Modify: `lib/todo_list.dart`

### Step 1: 添加导入和状态变量

在文件顶部添加导入：
```dart
import 'package:todo/week_group_header.dart';
import 'dart:collection';
```

在 `_TodoListState` 类中添加状态变量：
```dart
class _TodoListState extends State<TodoList> {
  List<Task> tasks = List.empty(growable: true);
  List<Task> finishedList = List.empty(growable: true);
  LinkedHashMap<String, List<Task>>? groupedFinishedTasks;
  Map<String, bool> weekExpandedState = {};
  FocusNode focusNode = FocusNode();

  // ... rest of existing code
}
```

### Step 2: 修改 reload 方法计算分组

```dart
reload() async {
  var todoList = await widget.driver.getTask();
  var finished = await widget.driver.getTask(finished: true);

  // 按周分组已完成任务
  final grouped = widget.driver.groupTasksByWeek(finished);

  // 初始化展开状态：本周展开，其他折叠
  final expandedState = <String, bool>{};
  if (grouped.isNotEmpty) {
    final firstWeek = grouped.keys.first;
    // 找出"本周"或者第一个非空周展开
    for (final label in grouped.keys) {
      if (label.startsWith('本周')) {
        expandedState[label] = true;
      } else {
        expandedState[label] = false;
      }
    }
    // 如果没有本周的任务，展开第一个有任务的周
    if (!expandedState.containsValue(true) && grouped.isNotEmpty) {
      expandedState[grouped.keys.first] = true;
    }
  }

  setState(() {
    tasks = todoList;
    finishedList = finished;
    groupedFinishedTasks = grouped;
    weekExpandedState = expandedState;
  });
}
```

### Step 3: 添加切换展开状态的方法

```dart
void toggleWeekExpanded(String weekLabel) {
  setState(() {
    weekExpandedState[weekLabel] = !(weekExpandedState[weekLabel] ?? false);
  });
}
```

### Step 4: 修改已完成任务渲染部分

找到 `ExpandButton` 下方的条件渲染部分，替换为使用分组数据：

```dart
ExpandButton(
  fold: widget.foldFinish,
  onPressed: (bool fold) {
    setState(() {
      widget.foldFinish = fold;
    });
  },
),
if (!widget.foldFinish && groupedFinishedTasks != null)
  ...groupedFinishedTasks!.entries.map((entry) {
    final weekLabel = entry.key;
    final weekTasks = entry.value;
    final isExpanded = weekExpandedState[weekLabel] ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WeekGroupHeader(
          label: weekLabel,
          taskCount: weekTasks.length,
          isExpanded: isExpanded,
          onToggle: () => toggleWeekExpanded(weekLabel),
        ),
        if (isExpanded)
          ...weekTasks.map((task) => TodoItem(
                update: (t) async {
                  if (!t.finished) {
                    await widget.driver.unfinish(t);
                    reload();
                    return;
                  }
                  widget.driver.update(t);
                },
                delete: (t) async {
                  await widget.driver.removeTask(t);
                  reload();
                },
                task: task,
              )),
      ],
    );
  }),
```

### Step 5: 处理空状态

如果已完成任务为空，显示提示。在 `if (!widget.foldFinish ...)` 之前添加：

```dart
if (!widget.foldFinish &&
    (groupedFinishedTasks == null || groupedFinishedTasks!.isEmpty))
  Container(
    padding: const EdgeInsets.all(32),
    alignment: Alignment.center,
    child: Text(
      "暂无已完成任务",
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 14,
      ),
    ),
  ),
```

### Step 6: 验证代码无语法错误

Run: `flutter analyze lib/todo_list.dart`
Expected: No errors

### Step 7: Commit

```bash
git add lib/todo_list.dart
git commit -m "feat: integrate weekly grouping into TodoList

- Add groupedFinishedTasks and weekExpandedState state variables
- Initialize week expansion: current week expanded, others collapsed
- Replace flat finished task list with collapsible week groups
- Add empty state message for no finished tasks

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 验证完整功能

### Step 1: 运行分析检查

Run: `flutter analyze`
Expected: No errors or warnings

### Step 2: 格式化代码

Run: `flutter format lib/`
Expected: Files formatted

### Step 3: 运行应用验证

Run: `flutter run -d macos` (或你的目标平台)
Expected:
- 已完成任务区域显示按周分组
- 本周默认展开
- 历史周默认折叠
- 点击分组标题可展开/折叠
- 任务数量显示正确

### Step 4: Commit

```bash
git add -A
git commit -m "chore: format code and finalize weekly grouping feature

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Summary

实施完成后，应用将：
1. 按自然周（周一到周日）分组显示已完成任务
2. 本周默认展开，历史周默认折叠
3. 显示每个周的任务数量和周标签
4. 点击分组标题可切换展开/折叠状态
5. 支持无完成时间任务的"未知时间"分组
