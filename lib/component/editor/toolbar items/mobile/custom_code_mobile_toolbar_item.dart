import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';

final customCodeMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: Icon(Unicon.code),
  actionHandler: (editorState, selection) =>
      editorState.toggleAttribute(AppFlowyRichTextKeys.code),
);
