import 'package:flutter/material.dart';
import '../unicon_icons.dart';

AlertDialog customAlertDialog(
  BuildContext context,
  String title,
  String label,
  String hint,
  void Function() onOk,
) {
  return AlertDialog(
    title: Text(title),
    content: TextField(
      autofocus: true,
      decoration: InputDecoration(
        label: Text(label),
        border: const OutlineInputBorder(),
        hintText: hint,
        icon: const Icon(Unicon.edit),
      ),
    ),
  );
}
