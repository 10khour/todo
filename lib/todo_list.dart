import 'package:flutter/material.dart';
import 'package:todo/task.dart';
import 'package:todo/todo_item.dart';

import 'expand_button.dart';

// ignore: must_be_immutable
class TodoList extends StatefulWidget {
  TaskDriver driver;
  bool foldFinish = true;
  TodoList({super.key, required this.driver});
  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoList> {
  List<Task> tasks = List.empty(growable: true);
  List<Task> finishedList = List.empty(growable: true);
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    OutlineInputBorder myinputborder() {
      //return type is OutlineInputBorder
      return OutlineInputBorder(
          //Outline border type for TextFeild
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ));
    }

    OutlineInputBorder myfocusborder() {
      return const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Color.fromRGBO(130, 77, 252, 0.9),
            width: 1,
          ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "任务",
          style: TextStyle(fontSize: 16),
        ),
        toolbarHeight: 35,
        backgroundColor: const Color.fromRGBO(130, 77, 252, 0.9),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 45,
              margin:
                  const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20)),
              child: TextField(
                focusNode: focusNode,
                autofocus: true,
                onSubmitted: (value) async {
                  controller.clear();
                  focusNode.requestFocus();
                  await widget.driver.addTask(Task(text: value));
                  await reload();
                },
                controller: controller,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 5, left: 15),
                    fillColor: Colors.grey.withOpacity(0.1),
                    filled: true,
                    hintText: "Add a task",
                    enabledBorder: myinputborder(),
                    focusedBorder: myfocusborder(),
                    border: myinputborder()),
              )),
          Expanded(
            child: ListView(
              children: [
                ...tasks
                    .map((e) => TodoItem(
                          update: (t) async {
                            if (t.finished) {
                              await widget.driver.finish(t);
                              reload();
                              return;
                            }
                            widget.driver.update(t);
                          },
                          delete: (t) async {
                            await widget.driver.removeTask(t);
                            reload();
                          },
                          task: e,
                        ))
                    .toList(),
                ExpandButton(
                  onPressed: (bool fold) {
                    setState(() {
                      widget.foldFinish = fold;
                    });
                  },
                ),
                if (!widget.foldFinish)
                  ...finishedList
                      .map((e) => TodoItem(
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
                            task: e,
                          ))
                      .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  reload() async {
    var todoList = await widget.driver.getTask();
    var finished = await widget.driver.getTask(finished: true);
    setState(() {
      tasks = todoList;
      finishedList = finished;
    });
  }

  loadFinishedList() async {}
  @override
  void initState() {
    super.initState();
    reload();
  }
}
