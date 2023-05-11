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
      appBar: AppBar(
        title: const Text("今日任务"),
        toolbarHeight: 40,
        backgroundColor: const Color.fromRGBO(130, 77, 252, 0.9),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              height: 38,
              margin:
                  const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
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
