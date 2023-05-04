import 'package:flutter/material.dart';
import 'package:todo/task.dart';
import 'package:todo/todo_item.dart';

// ignore: must_be_immutable
class TodoList extends StatefulWidget {
  List<Task> task = List.empty(growable: true);

  TodoList({super.key});
  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    const double titleWidth = 160;
    TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        style: BorderStyle.solid))),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: Row(children: [
                SizedBox(
                  width: (size - titleWidth) / 2.0,
                ),
                const SizedBox(
                  width: titleWidth,
                  child: Text(
                    '今日任务',
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                Expanded(child: Container()),
              ]),
            ),
          ),
          Container(
              height: 50,
              margin:
                  const EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 2),
              decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                onSubmitted: (value) {
                  setState(() {
                    widget.task.add(
                        Task(controller: TextEditingController(text: value)));
                  });
                },
                controller: controller,
                decoration: InputDecoration(
                    fillColor: Colors.grey.withOpacity(0.1),
                    filled: true,
                    hintText: "Add a task",
                    border: InputBorder.none),
              )),
          Expanded(
            child: ListView(
              children: widget.task
                  .map((e) => TodoItem(
                        stateChange: (t, state) {
                          widget.task
                              .firstWhere((element) => element.id == t.id)
                              .finished = state;
                        },
                        delete: (t) {
                          setState(() {
                            widget.task
                                .removeWhere((element) => element.id == t.id);
                          });
                        },
                        task: e,
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
