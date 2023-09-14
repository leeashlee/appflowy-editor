import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:noel_notes/custom_icon_item_widget.dart';

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
      return FloatingToolbar(
        items: [
          paragraphItem,
          ...headingItems,
          ...markdownFormatItems,
          quoteItem,
          bulletedListItem,
          numberedListItem,
          linkItem,
          // presets for coloring text
          /*buildTextColorItem(colorOptions: [
            const ColorOption(
              colorHex: "#ff0000",
              name: "red",
            )
          ]),*/
          buildHighlightColorItem(),
          ...textDirectionItems,
          ...alignmentItems,
          ToolbarItem(
            id: 'editor.textColor',
            group: 4,
            isActive: onlyShowInTextType,
            builder: (context, editorState, highlightColor) {
              String? textColorHex;
              final selection = editorState.selection!;
              final nodes = editorState.getNodesInSelection(selection);
              final isHighlight =
                  nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes((attributes) {
                  textColorHex = attributes[AppFlowyRichTextKeys.textColor];
                  return (textColorHex != null);
                });
              });
              return CustomSVGIconItemWidget(
                iconName: "toolbar/text_color",
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
                    currentColorHex: "#00ff00",
                    isTextColor: true,
                    textColorOptions: [
                      const ColorOption(colorHex: "#ff0000", name: "red"),
                    ],
                  );
                },
              );
            },
          ),
        ],
        editorState: editorState,
        scrollController: scrollController,
        style: FloatingToolbarStyle(backgroundColor: Theme.of(context).colorScheme.surfaceVariant, toolbarActiveColor: Theme.of(context).colorScheme.onSurfaceVariant),
        child: _buildDesktopEditor(
          context, editorState, null,
          //scrollController,
        ),
      );
    }
  }

  Widget _buildMobileEditor(
    BuildContext context,
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
          fontSize: 18.0,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        bold: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
        href: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          decoration: TextDecoration.combine(
            [
              TextDecoration.overline,
              TextDecoration.underline,
            ],
          ),
        ),
        code: TextStyle(
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
