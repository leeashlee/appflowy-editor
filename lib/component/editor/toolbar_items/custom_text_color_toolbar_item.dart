import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/component/editor/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';

ToolbarItem customBuildTextColorItem({
  List<ColorOption>? colorOptions,
}) {
  return ToolbarItem(
    id: 'editor.textColor',
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState, highlightColor) {
      String? textColorHex;
      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes((attributes) {
          textColorHex = attributes[AppFlowyRichTextKeys.textColor];
          return (textColorHex != null);
        });
      });
      return CustomSVGIconItemWidget(
        iconBuilder: (_) => Icon(
                Icons.format_color_text_rounded,
                size: 16,
                color: isHighlight
                    ? highlightColor
                    : Theme.of(context).colorScheme.primary,
              ),
        isHighlight: isHighlight,
        highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
        normalColor: Theme.of(context).colorScheme.primary,
        iconSize: const Size.square(14),
        tooltip: AppFlowyEditorLocalizations.current.textColor,
        onPressed: () {
          showColorMenu(
            context,
            editorState,
            selection,
            currentColorHex: textColorHex,
            isTextColor: true,
            textColorOptions: colorOptions,
          );
        },
      );
    },
  );
}
