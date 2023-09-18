import 'package:flutter/material.dart';

AlertDialog customAlertDialog(
  BuildContext context,
  String title,
  String label,
  String hint,
  Widget? icon,
  TextEditingController controller,
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
        icon: icon,
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => {
          Navigator.pop(context, 'Cancel'),
          controller.clear(),
        },
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          onOk();
            Navigator.pop(context, 'OK');
          },
        child: const Text('OK'),
      ),
    ],
  );
}
