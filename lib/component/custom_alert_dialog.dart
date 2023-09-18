import 'package:flutter/material.dart';
import 'package:noel_notes/component/custom_text_field.dart';

AlertDialog customAlertDialog(
  BuildContext context,
  String title,
  String label,
  String hint,
  Widget icon,
  void Function(String input) onOk,
) {
  CustomTextField textField = CustomTextField(title, label, hint, icon);
  return AlertDialog(
    title: Text(title),
    content: textField,
    actions: <Widget>[
      TextButton(
        onPressed: () => {
          Navigator.pop(context, 'Cancel'),
        },
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          onOk(textField.getText());
          Navigator.pop(context, 'OK');
        },
        child: const Text('OK'),
      ),
    ],
  );
}
