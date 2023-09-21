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

class DesktopEditor extends StatefulWidget {
  const DesktopEditor({
    super.key,
    required this.editorState,
    this.textDirection = TextDirection.ltr,
  });

  final EditorState editorState;
  final TextDirection textDirection;

  @override
  State<DesktopEditor> createState() => _DesktopEditorState();
}

class _DesktopEditorState extends State<DesktopEditor> {
  EditorState get editorState => widget.editorState;

  late final EditorScrollController editorScrollController;

  late EditorStyle editorStyle;
  late Map<String, BlockComponentBuilder> blockComponentBuilders;
  late List<CommandShortcutEvent> commandShortcuts;

  @override
  void initState() {
    super.initState();

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );

    editorStyle = _buildDesktopEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
    commandShortcuts = _buildCommandShortcuts();
  }

  @override
  void reassemble() {
    super.reassemble();

    editorStyle = _buildDesktopEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
    commandShortcuts = _buildCommandShortcuts();
  }

  @override
  Widget build(BuildContext context) {
    assert(PlatformExtension.isDesktopOrWeb);
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
      style: FloatingToolbarStyle(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        toolbarActiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Directionality(
        textDirection: widget.textDirection,
        child: AppFlowyEditor(
          editorState: editorState,
          editorScrollController: editorScrollController,
          blockComponentBuilders: blockComponentBuilders,
          commandShortcutEvents: commandShortcuts,
          editorStyle: editorStyle,
          header: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Image.asset(
              'assets/images/header.png',
              fit: BoxFit.fitWidth,
              height: 150,
            ),
          ),
          footer: const SizedBox(
            height: 100,
          ),
        ),
      ),
    );
  }

  // showcase 1: customize the editor style.
  EditorStyle _buildDesktopEditorStyle() {
    return EditorStyle.desktop(
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
      padding: const EdgeInsets.symmetric(horizontal: 200.0),
    );
  }

  // showcase 2: customize the block style
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,
    };
    // customize the image block component to show a menu
    map[ImageBlockKeys.type] = ImageBlockComponentBuilder(
      showMenu: true,
      menuBuilder: (node, _) {
        return const Positioned(
          right: 10,
          child: Text('⭐️ Here is a menu!'),
        );
      },
    );
    // customize the heading block component
    final levelToFontSize = [
      30.0,
      26.0,
      22.0,
      18.0,
      16.0,
      14.0,
    ];
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      textStyleBuilder: (level) => GoogleFonts.poppins(
        fontSize: levelToFontSize.elementAtOrNull(level - 1) ?? 14.0,
        fontWeight: FontWeight.w600,
      ),
    );
    // customize the padding
    map.forEach((key, value) {
      value.configuration = BlockComponentConfiguration(
        padding: (_) => const EdgeInsets.symmetric(vertical: 8.0),
      );
    });
    return map;
  }

  // showcase 3: customize the command shortcuts
  List<CommandShortcutEvent> _buildCommandShortcuts() {
    return [
      // customize the highlight color
      customToggleHighlightCommand(
        style: ToggleColorsStyle(
          highlightColor: Colors.orange.shade700,
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
    ];
  }
}
