import 'package:appflowy_editor/appflowy_editor.dart';
// ignore: implementation_imports
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/tooltip_util.dart';
import 'package:noel_notes/component/editor/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';

final List<ToolbarItem> customMarkdownFormatItems = [
  _FormatToolbarItem(
    id: 'underline',
    name: 'underline',
    tooltip:
        '${AppFlowyEditorLocalizations.current.underline}${shortcutTooltips('⌘ + U', 'CTRL + U', 'CTRL + U')}',
    icon: Unicon.underline,
  ),
  _FormatToolbarItem(
    id: 'bold',
    name: 'bold',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}',
    icon: Unicon.bold,
  ),
  _FormatToolbarItem(
    id: 'italic',
    name: 'italic',
    tooltip:
        '${AppFlowyEditorLocalizations.current.italic}${shortcutTooltips('⌘ + I', 'CTRL + I', 'CTRL + I')}',
    icon: Unicon.italic,
  ),
  _FormatToolbarItem(
    id: 'strikethrough',
    name: 'strikethrough',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${shortcutTooltips('⌘ + SHIFT + S', 'CTRL + SHIFT + S', 'CTRL + SHIFT + S')}',
    icon: Unicon.text_strike_through,
  ),
  _FormatToolbarItem(
    id: 'code',
    name: 'code',
    tooltip:
        '${AppFlowyEditorLocalizations.current.embedCode}${shortcutTooltips('⌘ + E', 'CTRL + E', 'CTRL + E')}',
    icon: Unicon.code,
  ),
];

class _FormatToolbarItem extends ToolbarItem {
  _FormatToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required IconData icon,
  }) : super(
          id: 'editor.$id',
          group: 2,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
              return delta.everyAttributes(
                (attributes) => attributes[name] == true,
              );
            });
            return CustomSVGIconItemWidget(
              iconBuilder: (_) => Icon(
                icon,
                size: 16,
                color: isHighlight
                    ? highlightColor
                    : Theme.of(context).colorScheme.primary,
              ),
              isHighlight: isHighlight,
              highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
              normalColor: Theme.of(context).colorScheme.primary,
              tooltip: tooltip,
              onPressed: () => editorState.toggleAttribute(name),
            );
          },
        );
}
