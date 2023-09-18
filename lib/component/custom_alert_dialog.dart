import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';

AlertDialog customAlertDialog(BuildContext context, void Function() onOk) {
  return AlertDialog(
    title: const Text('Create a new note?'),
    content: const TextField(
      autofocus: true,
      decoration: InputDecoration(
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
