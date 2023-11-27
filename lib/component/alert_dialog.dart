import 'package:flutter/material.dart';
import 'package:noel_notes/component/text_field.dart';

import 'icons/unicon_icons.dart';

enum AlertType {
  newFile(
    title: "Create a new note?",
    label: "Note Name:",
    hint: "Untitled",
    icon: Icon(Unicon.edit_alt),
  ),
  newCollec(
    title: "Create a new note collection?",
    label: "Note Collection Name:",
    hint: "My Notes",
    icon: Icon(Unicon.book_open),
  ),
  renameFile(
    title: "Rename the note?",
    label: "Note Name:",
    hint: "Untitled",
    icon: Icon(Unicon.edit_alt),
  ),
  delFile(
    title: "Delete the note?",
    label: null,
    hint: null,
    icon: Icon(Unicon.trash_alt),
  );

  const AlertType({
    required this.title,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final String title;
  final String? label;
  final String? hint;
  final Widget icon;
}

class CustomAlertDialog extends StatelessWidget {
  final AlertType type;
  final void Function(String? input) onOk;

  const CustomAlertDialog(this.type, this.onOk, {super.key});

  @override
  Widget build(BuildContext context) {
    CustomTextField? field;
    if (type.label != null && type.hint != null) {
      field = CustomTextField(
        type.title,
        type.label!,
        type.hint!,
        type.icon,
      );
    }

    return AlertDialog(
      title: Text(type.title),
      content: field,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            onOk(field?.getText());
            Navigator.pop(context, 'OK');
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
