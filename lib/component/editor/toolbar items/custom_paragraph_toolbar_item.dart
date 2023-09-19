import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/component/editor/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';

final ToolbarItem customParagraphItem = ToolbarItem(
  id: 'editor.paragraph',
  group: 1,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'paragraph';
    final delta = (node.delta ?? Delta()).toJson();
    return CustomSVGIconItemWidget(
      iconName: 'toolbar/text',
      isHighlight: isHighlight,
      highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
      normalColor: Theme.of(context).colorScheme.primary,
      tooltip: AppFlowyEditorLocalizations.current.text,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: ParagraphBlockKeys.type,
          attributes: {
            blockComponentDelta: delta,
            blockComponentBackgroundColor:
                node.attributes[blockComponentBackgroundColor],
            blockComponentTextDirection:
                node.attributes[blockComponentTextDirection],
          },
        ),
      ),
    );
  },
);
