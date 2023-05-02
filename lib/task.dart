import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Task {
  String id = "";
  bool finished = true;
  TextEditingController controller;
  Task({required this.controller, this.finished = false}) {
    var uuid = Uuid();
    id = uuid.v4();
  }
}
