import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:noel_notes/component/editor/toolbar%20items/custom_alignment_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_bulleted_list_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_format_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_heading_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_highlight_color_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_link_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_numbered_list_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_paragraph_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_quote_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_text_color_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar%20items/custom_text_direction_toolbar_items.dart';

class Editor extends StatelessWidget {
  const Editor({
    super.key,
    required this.editorState,
    required this.onEditorStateChange,
  });

  final EditorState editorState;
  final void Function(EditorState editorState) onEditorStateChange;

  @override
  Widget build(BuildContext context) {
    editorState.logConfiguration
      ..handler = debugPrint
      ..level = LogLevel.off;
    editorState.transactionStream.listen((event) {
      if (event.$1 == TransactionTime.after) {
        onEditorStateChange(editorState);
      }
    });
    final scrollController = ScrollController();
    if (PlatformExtension.isMobile) {
      return Column(
        children: [
          Expanded(
            child: _buildMobileEditor(
              context,
              customizeEditorStyle(context),
              editorState,
              null,
              //scrollController,
            ),
          ),
          MobileToolbar(
            editorState: editorState,
            toolbarItems: [
              textDecorationMobileToolbarItem,
              buildTextAndBackgroundColorMobileToolbarItem(),
              headingMobileToolbarItem,
              todoListMobileToolbarItem,
              listMobileToolbarItem,
              linkMobileToolbarItem,
              quoteMobileToolbarItem,
              dividerMobileToolbarItem,
              codeMobileToolbarItem,
            ],
          ),
        ],
      );
    } else {
      //FIXME material colors to sync and for the toolbar to work on all note
      return FloatingToolbar(
        items: [
          customParagraphItem,
          ...customheadingItems,
          ...customMarkdownFormatItems,
          customQuoteItem,
          customBulletedListItem,
          customNumberedListItem,
          customLinkItem,
          customBuildTextColorItem(),
          customBuildHighlightColorItem(),
          ...customTextDirectionItems,
          ...customAlignmentItems,
        ],
        editorState: editorState,
        scrollController: scrollController,
        style: FloatingToolbarStyle(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          toolbarActiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: _buildDesktopEditor(
          context, editorState, null,
          //scrollController,
        ),
      );
    }
  }

  Widget _buildMobileEditor(
    BuildContext context,
    EditorStyle editorStyle,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    return AppFlowyEditor(
      editorStyle: customizeEditorStyle(context),
      editorState: editorState,
      scrollController: scrollController,
    );
  }

  Widget _buildDesktopEditor(
    BuildContext context,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    final customBlockComponentBuilders = {
      ...standardBlockComponentBuilderMap,
      ImageBlockKeys.type: ImageBlockComponentBuilder(
        showMenu: true,
        menuBuilder: (node, _) {
          return const Positioned(
            right: 10,
            child: Text('Sample Menu'),
          );
        },
      ),
    };
    return AppFlowyEditor(
      editorState: editorState,
      shrinkWrap: false,
      //scrollController: scrollController,
      blockComponentBuilders: customBlockComponentBuilders,
      commandShortcutEvents: [
        customToggleHighlightCommand(
          style: ToggleColorsStyle(
            highlightColor: Theme.of(context).highlightColor,
          ),
        ),
        ...[
          ...standardCommandShortcutEvents
            ..removeWhere(
              (el) => el == toggleHighlightCommand,
            ),
        ],
        ...findAndReplaceCommands(
          context: context,
          localizations: FindReplaceLocalizations(
            find: 'Find',
            previousMatch: 'Previous match',
            nextMatch: 'Next match',
            close: 'Close',
            replace: 'Replace',
            replaceAll: 'Replace all',
          ),
        ),
      ],
      characterShortcutEvents: standardCharacterShortcutEvents,
      editorStyle: customizeEditorStyle(context),
    );
  }

  EditorStyle customizeEditorStyle(BuildContext context) {
    return EditorStyle(
      padding: PlatformExtension.isDesktopOrWeb
          ? const EdgeInsets.only(left: 50, right: 50, top: 20)
          : const EdgeInsets.symmetric(horizontal: 20),
      cursorColor: Theme.of(context).colorScheme.primary,
      selectionColor:
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      textStyleConfiguration: TextStyleConfiguration(
        text: TextStyle(
          fontFamily: GoogleFonts.miriamLibre().fontFamily,
          fontSize: 18.0,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        bold: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
        href: TextStyle(
          fontFamily: GoogleFonts.miriamLibre().fontFamily,
          color: Theme.of(context).colorScheme.secondary,
          decoration: TextDecoration.combine(
            [
              TextDecoration.overline,
              TextDecoration.underline,
            ],
          ),
        ),
        code: TextStyle(
          fontFamily: GoogleFonts.miriamLibre().fontFamily,
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ),
      textSpanDecorator: (context, node, index, text, textSpan) {
        final attributes = text.attributes;
        final href = attributes?[AppFlowyRichTextKeys.href];
        if (href != null) {
          return TextSpan(
            text: text.text,
            style: textSpan.style,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                debugPrint('onTap: $href');
              },
          );
        }
        return textSpan;
      },
    );
  }
}
