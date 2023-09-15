import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/custom_icon_item_widget.dart';
import 'package:flutter/material.dart';

final List<ToolbarItem> customAlignmentItems = [
  _AlignmentToolbarItem(
    id: 'align_left',
    name: 'left',
    tooltip: 'left',
    icon: Icons.format_align_left,
    align: 'left',
  ),
  _AlignmentToolbarItem(
    id: 'align_center',
    name: 'center',
    tooltip: 'center',
    icon: Icons.format_align_center,
    align: 'center',
  ),
  _AlignmentToolbarItem(
    id: 'align_right',
    name: 'right',
    tooltip: 'right',
    icon: Icons.format_align_right,
    align: 'right',
  ),
];

class _AlignmentToolbarItem extends ToolbarItem {
  _AlignmentToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required IconData icon,
    required String align,
  }) : super(
          id: 'editor.$id',
          group: 6,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every(
              (n) => n.attributes[blockComponentAlign] == align,
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
                    blockComponentAlign: align,
                  },
                ),
              ),
            );
          },
        );
}
