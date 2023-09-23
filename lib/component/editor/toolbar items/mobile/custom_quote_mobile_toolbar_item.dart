import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/cupertino.dart';

final customQuoteMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: Icon(CupertinoIcons.text_quote),
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
