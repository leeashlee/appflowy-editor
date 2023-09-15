import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';

final ToolbarItem customBulletedListItem = ToolbarItem(
  id: 'editor.bulleted_list',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'bulleted_list';
    return CustomSVGIconItemWidget(
      iconName: 'toolbar/bulleted_list',
      isHighlight: isHighlight,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
      normalColor: Theme.of(context).colorScheme.primary,
      tooltip: AppFlowyEditorLocalizations.current.bulletedList,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'bulleted_list',
        ),
      ),
    );
  },
);
