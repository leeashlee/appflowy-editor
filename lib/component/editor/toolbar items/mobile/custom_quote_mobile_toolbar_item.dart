import 'package:appflowy_editor/appflowy_editor.dart';

final customQuoteMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: AFMobileIcon(afMobileIcons: AFMobileIcons.quote),
  actionHandler: ((editorState, selection) {
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isQuote = node.type == QuoteBlockKeys.type;
    editorState.formatNode(
      selection,
      (node) => node.copyWith(
        type: isQuote ? ParagraphBlockKeys.type : QuoteBlockKeys.type,
        attributes: {
          ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
        },
      ),
    );
  }),
);
