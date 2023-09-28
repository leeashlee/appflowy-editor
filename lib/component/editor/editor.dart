import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_alignment_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_bulleted_list_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_format_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_heading_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_highlight_color_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_link_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_numbered_list_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_paragraph_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_quote_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_text_color_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/custom_text_direction_toolbar_items.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_code_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_divider_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_heading_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_link_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_list_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_quote_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_text_and_background_color_tool_bar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_text_decoration_mobile_toolbar_item.dart';
import 'package:noel_notes/component/editor/toolbar_items/mobile/custom_todo_list_mobile_toolbar_item.dart';

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
    final EditorScrollController editorScrollController = EditorScrollController(editorState: editorState);
    if (PlatformExtension.isMobile) {
      return Column(
        children: [
          Expanded(
            child: _buildMobileEditor(
              context,
              editorState,
              editorScrollController,
            ),
          ),
          MobileToolbar(
            backgroundColor: Theme.of(context).colorScheme.background,
            foregroundColor: Theme.of(context).colorScheme.onBackground,
            clearDiagonalLineColor: Theme.of(context).colorScheme.tertiary,
            tabbarSelectedBackgroundColor:
                Theme.of(context).colorScheme.surface,
            tabbarSelectedForegroundColor:
                Theme.of(context).colorScheme.onSurface,
            itemOutlineColor: Theme.of(context).colorScheme.outline,
            itemHighlightColor: Theme.of(context).colorScheme.inversePrimary,
            outlineColor: Theme.of(context).colorScheme.outline,
            primaryColor: Theme.of(context).colorScheme.primary,
            onPrimaryColor: Theme.of(context).colorScheme.onPrimary,
            editorState: editorState,
            toolbarItems: [
              customTextDecorationMobileToolbarItem,
              customBuildTextAndBackgroundColorMobileToolbarItem(),
              customHeadingMobileToolbarItem,
              customTodoListMobileToolbarItem,
              customListMobileToolbarItem,
              customLinkMobileToolbarItem,
              customQuoteMobileToolbarItem,
              customDividerMobileToolbarItem,
              customCodeMobileToolbarItem,
            ],
          ),
        ],
      );
    } else {
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
        editorScrollController: editorScrollController,
        //FIXME material colors to sync
        style: FloatingToolbarStyle(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          toolbarActiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: _buildDesktopEditor(
          context,
          editorState,
          editorScrollController,
        ),
      );
    }
  }

  Widget _buildMobileEditor(
    BuildContext context,
    EditorState editorState,
    EditorScrollController? editorScrollController,
  ) {
    return AppFlowyEditor(
      editorStyle: customizeEditorStyle(context),
      editorState: editorState,
      editorScrollController: editorScrollController,
    );
  }

  Widget _buildDesktopEditor(
    BuildContext context,
    EditorState editorState,
    EditorScrollController? editorScrollController,
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
      editorScrollController: editorScrollController,
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
          ? const EdgeInsets.symmetric(horizontal: 50)
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
