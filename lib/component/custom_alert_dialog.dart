import 'package:flutter/material.dart';

AlertDialog CustomAlertDialog(BuildContext context, void Function() onOk) {
  return AlertDialog(
    title: const Text('Create a new note?'),
    content: TextField(
      autofocus: true,
      decoration: const InputDecoration(
        label: Text('Note Name:'),
        border: OutlineInputBorder(),
        hintText: 'Untitled',
        icon: Icon(Unicon.edit),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: onOk,
        child: const Text('OK'),
      ),
    ],
  );
}
