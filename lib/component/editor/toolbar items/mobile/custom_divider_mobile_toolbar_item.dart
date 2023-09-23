import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';

final customDividerMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: const Icon(Unicon.ellipsis_h),
  actionHandler: ((editorState, selection) {
    // same as the [handler] of [dividerMenuItem] in Desktop
    final selection = editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final path = selection.end.path;
    final node = editorState.getNodeAtPath(path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }
    final insertedPath = delta.isEmpty ? path : path.next;
    final transaction = editorState.transaction
      ..insertNode(insertedPath, dividerNode())
      ..insertNode(insertedPath, paragraphNode())
      ..afterSelection = Selection.collapsed(Position(path: insertedPath.next));
    editorState.apply(transaction);
  }),
);
