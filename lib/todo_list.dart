import 'package:flutter/material.dart';
import 'package:todo/task.dart';
import 'package:todo/todo_item.dart';

class TodoList extends StatefulWidget {
  List<Task> task = List.empty(growable: true);
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
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  onSubmitted: (value) {
                    setState(() {
                      widget.task.add(
                          Task(controller: TextEditingController(text: value)));
                    });
                    print("add");
                  },
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: "Add Task", border: InputBorder.none),
                ),
              )),
          Expanded(
            child: ListView(
              children: widget.task
                  .map((e) => TodoItem(
                        delete: (id) {
                          setState(() {
                            print("remove ${id}");

                            widget.task
                                .removeWhere((element) => element.id == id);
                            print("${widget.task.length}");
                          });
                        },
                        task: Task(
                            controller: e.controller, finished: e.finished),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
