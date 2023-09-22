import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';

final customTodoListMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: Icon(Unicon.check_circle),
  actionHandler: (editorState, selection) async {
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isTodoList = node.type == TodoListBlockKeys.type;

    editorState.formatNode(
      selection,
      (node) => node.copyWith(
        type: isTodoList ? ParagraphBlockKeys.type : TodoListBlockKeys.type,
        attributes: {
          TodoListBlockKeys.checked: false,
          ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
        },
      ),
    );
  },
);
