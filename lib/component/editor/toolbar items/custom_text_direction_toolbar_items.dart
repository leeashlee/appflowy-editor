import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/component/editor/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/component/icons/unicon_icons.dart';

final List<ToolbarItem> customTextDirectionItems = [
  _TextDirectionToolbarItem(
    id: 'text_direction_auto',
    name: blockComponentTextDirectionAuto,
    tooltip: AppFlowyEditorLocalizations.current.auto,
    icon: Icons.swap_horiz,
  ),
  _TextDirectionToolbarItem(
    id: 'text_direction_ltr',
    name: blockComponentTextDirectionLTR,
    tooltip: AppFlowyEditorLocalizations.current.ltr,
    icon: Unicon.left_to_right_text_direction,
  ),
  _TextDirectionToolbarItem(
    id: 'text_direction_rtl',
    name: blockComponentTextDirectionRTL,
    tooltip: AppFlowyEditorLocalizations.current.rtl,
    icon: Unicon.right_to_left_text_direction,
  ),
];

class _TextDirectionToolbarItem extends ToolbarItem {
  _TextDirectionToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required IconData icon,
  }) : super(
          id: 'editor.$id',
          group: 7,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every(
              (n) => n.attributes[blockComponentTextDirection] == name,
            );
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
              onPressed: () => editorState.updateNode(
                selection,
                (node) => node.copyWith(
                  attributes: {
                    ...node.attributes,
                    blockComponentTextDirection: isHighlight ? null : name,
                  },
                ),
              ),
            );
          },
        );
}
