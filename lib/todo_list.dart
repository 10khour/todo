import 'package:flutter/material.dart';
import 'package:todo/task.dart';
import 'package:todo/todo_item.dart';

// ignore: must_be_immutable
class TodoList extends StatefulWidget {
  List<Task> task = List.empty(growable: true);
  TaskDriver driver;
  TodoList({super.key, required this.driver});
  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    FocusNode focusNode = FocusNode();
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
        mainAxisSize: MainAxisSize.max,
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
                autofocus: true,
                onSubmitted: (value) async {
                  controller.clear();
                  await widget.driver.addTask(Task(text: value));
                  await reload();
                  focusNode.requestFocus();
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
              children: widget.task
                  .map((e) => TodoItem(
                        update: (t) {
                          widget.driver.update(t);
                        },
                        delete: (t) async {
                          await widget.driver.removeTask(t);
                          reload();
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

  reload() async {
    var tasks = await widget.driver.getTask();
    setState(() {
      widget.task = tasks;
    });
  }

  @override
  void initState() {
    super.initState();
    reload();
  }
}
