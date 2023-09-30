import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/component/icons/unicon_icons.dart';

final customCodeMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: const Icon(Unicon.code),
  actionHandler: (editorState, selection) =>
      editorState.toggleAttribute(AppFlowyRichTextKeys.code),
);
