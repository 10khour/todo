import 'package:flutter/material.dart';
import 'package:todo/task.dart';

// ignore: must_be_immutable
class TodoItem extends StatefulWidget {
  Task task;

  Function(Task task)? delete;
  Function(Task task)? update;

  TodoItem({super.key, required this.task, this.delete, this.update});

  @override
  State<StatefulWidget> createState() {
    return _TodoItemState();
  }
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 2),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              Checkbox(
                activeColor: const Color.fromRGBO(130, 77, 252, 0.9),
                value: widget.task.finished,
                onChanged: (v) {
                  setState(() {
                    widget.task.finished = v!;
                    if (widget.update != null) {
                      widget.update!(widget.task);
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
                onChanged: (value) {
                  if (widget.update != null) {
                    widget.task.text = value;
                    widget.update!(widget.task);
                  }
                },
                style: TextStyle(
                    decorationThickness: 2.8,
                    decorationColor: const Color.fromRGBO(130, 77, 252, 0.9),
                    decoration: widget.task.finished
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
                decoration: const InputDecoration(border: InputBorder.none),
                controller: getTextEditController(widget.task.text),
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
        ),
      ],
    );
  }

  getTextEditController(String text) {
    return TextEditingController(text: text);
  }
}
