import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';

final ToolbarItem customQuoteItem = ToolbarItem(
  id: 'editor.quote',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'quote';
    return CustomSVGIconItemWidget(
      iconName: 'toolbar/quote',
      isHighlight: isHighlight,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
      normalColor: Theme.of(context).colorScheme.primary,
      tooltip: AppFlowyEditorLocalizations.current.quote,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'quote',
        ),
      ),
    );
  },
);
