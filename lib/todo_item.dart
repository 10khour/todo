import 'package:flutter/material.dart';
import 'package:todo/task.dart';

// ignore: must_be_immutable
class TodoItem extends StatefulWidget {
  Task task;

  Function(Task task)? delete;
  Function(Task task, bool state)? stateChange;

  TodoItem({super.key, required this.task, this.delete, this.stateChange});

  @override
  State<StatefulWidget> createState() {
    return _TodoItemState();
  }
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 2),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(8)),
      height: 50,
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          Checkbox(
            activeColor: Colors.teal,
            value: widget.task.finished,
            onChanged: (v) {
              setState(() {
                widget.task.finished = v!;
                if (widget.stateChange != null) {
                  widget.stateChange!(widget.task, v);
                }
              });
            },
            shape: const CircleBorder(),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            style: TextStyle(
                decoration: widget.task.finished
                    ? TextDecoration.lineThrough
                    : TextDecoration.none),
            decoration: const InputDecoration(border: InputBorder.none),
            controller: widget.task.controller,
          )),
          IconButton(
              onPressed: () {
                if (widget.delete != null) {
                  widget.delete!(widget.task);
                }
              },
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.grey,
              )),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }
}
