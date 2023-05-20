import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExpandButton extends StatefulWidget {
  BoxDecoration? decoration;
  bool fold = true;

  Function(bool) onPressed;
  ExpandButton(
      {super.key, this.decoration, this.fold = false, required this.onPressed});
  @override
  State<StatefulWidget> createState() {
    return _ExpandButtonState();
  }
}

class _ExpandButtonState extends State<ExpandButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            if (widget.fold) {
              widget.fold = false;
            } else {
              widget.fold = true;
            }
            widget.onPressed(widget.fold);
          });
        },
        child: Container(
          decoration: widget.decoration,
          child: Row(children: [
            const Spacer(),
            widget.fold
                ? const Text(
                    "显示已经完成事项",
                    style: TextStyle(color: Colors.grey),
                  )
                : const Text(
                    "隐藏已经完成事项",
                  ),
            widget.fold
                ? const Icon(
                    Icons.expand_more,
                    color: Colors.grey,
                  )
                : const Icon(Icons.expand_less),
            const Spacer(),
          ]),
        ));
  }
}
