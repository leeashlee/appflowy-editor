import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final customCodeMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: AFMobileIcon(afMobileIcons: AFMobileIcons.code, color: Theme.of(context).colorScheme.primary,),
  actionHandler: (editorState, selection) =>
      editorState.toggleAttribute(AppFlowyRichTextKeys.code),
);
