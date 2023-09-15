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
          //paragraphItem,
          ...headingItems,
          ...markdownFormatItems,
          //quoteItem,
          //bulletedListItem,
          //numberedListItem,
          //linkItem,
          buildHighlightColorItem(),
          ...textDirectionItems,
          ...alignmentItems,
          ToolbarItem(
            id: 'onlyShowInSingleSelectionAndTextType',
            group: 1,
            isActive: onlyShowInTextType,
            builder: (context, editorState, highlightColor) {
              final selection = editorState.selection!;
              final node = editorState.getNodeAtPath(selection.start.path)!;
              final isHighlight = node.type == 'paragraph';
              final delta = (node.delta ?? Delta()).toJson();
              return CustomSVGIconItemWidget(
                iconName: "toolbar/text",
                isHighlight: isHighlight,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                normalColor: Theme.of(context).colorScheme.primary,
                iconSize: const Size.square(14),
                tooltip: AppFlowyEditorLocalizations.current.text,
                onPressed: () => editorState.formatNode(
                  selection,
                  (node) => node.copyWith(
                    type: ParagraphBlockKeys.type,
                    attributes: {
                      blockComponentDelta: delta,
                      blockComponentBackgroundColor:
                          node.attributes[blockComponentBackgroundColor],
                      blockComponentTextDirection:
                          node.attributes[blockComponentTextDirection],
                    },
                  ),
                ),
              );
            },
          ),
          ToolbarItem(
            id: 'editor.quote',
            group: 3,
            isActive: onlyShowInSingleSelectionAndTextType,
            builder: (context, editorState, highlightColor) {
              final selection = editorState.selection!;
              final node = editorState.getNodeAtPath(selection.start.path)!;
              final isHighlight = node.type == 'quote';
              return CustomSVGIconItemWidget(
                iconName: 'toolbar/quote',
                isHighlight: isHighlight,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                normalColor: Theme.of(context).colorScheme.primary,
                iconSize: const Size.square(14),
                tooltip: AppFlowyEditorLocalizations.current.quote,
                onPressed: () => editorState.formatNode(
                  selection,
                  (node) => node.copyWith(
                    type: isHighlight ? 'paragraph' : 'quote',
                  ),
                ),
              );
            },
          ),
          ToolbarItem(
            id: 'editor.bulleted_list',
            group: 3,
            isActive: onlyShowInSingleSelectionAndTextType,
            builder: (context, editorState, highlightColor) {
              final selection = editorState.selection!;
              final node = editorState.getNodeAtPath(selection.start.path)!;
              final isHighlight = node.type == 'bulleted_list';
              return CustomSVGIconItemWidget(
                iconName: 'toolbar/bulleted_list',
                isHighlight: isHighlight,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                normalColor: Theme.of(context).colorScheme.primary,
                tooltip: AppFlowyEditorLocalizations.current.bulletedList,
                onPressed: () => editorState.formatNode(
                  selection,
                  (node) => node.copyWith(
                    type: isHighlight ? 'paragraph' : 'bulleted_list',
                  ),
                ),
              );
            },
          ),
          ToolbarItem(
            id: 'editor.numbered_list',
            group: 3,
            isActive: onlyShowInSingleSelectionAndTextType,
            builder: (context, editorState, highlightColor) {
              final selection = editorState.selection!;
              final node = editorState.getNodeAtPath(selection.start.path)!;
              final isHighlight = node.type == 'numbered_list';
              return CustomSVGIconItemWidget(
                iconName: 'toolbar/numbered_list',
                isHighlight: isHighlight,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                normalColor: Theme.of(context).colorScheme.primary,
                tooltip: AppFlowyEditorLocalizations.current.numberedList,
                onPressed: () => editorState.formatNode(
                  selection,
                  (node) => node.copyWith(
                    type: isHighlight ? 'paragraph' : 'numbered_list',
                  ),
                ),
              );
            },
          ),
          ToolbarItem(
            id: 'editor.link',
            group: 4,
            isActive: onlyShowInSingleSelectionAndTextType,
            builder: (context, editorState, highlightColor) {
              final selection = editorState.selection!;
              final nodes = editorState.getNodesInSelection(selection);
              final isHref = nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes(
                  (attributes) => attributes[AppFlowyRichTextKeys.href] != null,
                );
              });

              return CustomSVGIconItemWidget(
                iconName: 'toolbar/link',
                isHighlight: isHref,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                normalColor: Theme.of(context).colorScheme.primary,
                tooltip: AppFlowyEditorLocalizations.current.link,
                onPressed: () {
                  showLinkMenu(context, editorState, selection, isHref);
                },
              );
            },
          ),
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
                      ColorOption(
                        colorHex: Colors.grey.toHex(),
                        name: AppFlowyEditorLocalizations.current.fontColorGray,
                      ),
                      ColorOption(
                        colorHex: Colors.brown.toHex(),
                        name:
                            AppFlowyEditorLocalizations.current.fontColorBrown,
                      ),
                      ColorOption(
                        colorHex: Colors.yellow.toHex(),
                        name:
                            AppFlowyEditorLocalizations.current.fontColorYellow,
                      ),
                      ColorOption(
                        colorHex: Colors.green.toHex(),
                        name:
                            AppFlowyEditorLocalizations.current.fontColorGreen,
                      ),
                      ColorOption(
                        colorHex: Colors.blue.toHex(),
                        name: AppFlowyEditorLocalizations.current.fontColorBlue,
                      ),
                      ColorOption(
                        colorHex: Colors.purple.toHex(),
                        name:
                            AppFlowyEditorLocalizations.current.fontColorPurple,
                      ),
                      ColorOption(
                        colorHex: Colors.pink.toHex(),
                        name: AppFlowyEditorLocalizations.current.fontColorPink,
                      ),
                      ColorOption(
                        colorHex: Colors.red.toHex(),
                        name: AppFlowyEditorLocalizations.current.fontColorRed,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ToolbarItem(
            id: 'editor.highlightColor',
            group: 4,
            isActive: onlyShowInTextType,
            builder: (context, editorState, highlightColor) {
              String? highlightColorHex;

              final selection = editorState.selection!;
              final nodes = editorState.getNodesInSelection(selection);
              final isHighlight =
                  nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes((attributes) {
                  highlightColorHex =
                      attributes[AppFlowyRichTextKeys.highlightColor];
                  return highlightColorHex != null;
                });
              });
              return CustomSVGIconItemWidget(
                iconName: 'toolbar/highlight_color',
                iconSize: const Size.square(14),
                isHighlight: isHighlight,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                normalColor: Theme.of(context).colorScheme.primary,
                tooltip: AppFlowyEditorLocalizations.current.highlightColor,
                onPressed: () {
                  showColorMenu(
                    context,
                    editorState,
                    selection,
                    currentColorHex: "#00ff00",
                    isTextColor: false,
                    textColorOptions: [
                      ColorOption(
                        colorHex: Colors.grey.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorGray,
                      ),
                      ColorOption(
                        colorHex: Colors.brown.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorBrown,
                      ),
                      ColorOption(
                        colorHex: Colors.yellow.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorYellow,
                      ),
                      ColorOption(
                        colorHex: Colors.green.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorGreen,
                      ),
                      ColorOption(
                        colorHex: Colors.blue.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorBlue,
                      ),
                      ColorOption(
                        colorHex: Colors.purple.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorPurple,
                      ),
                      ColorOption(
                        colorHex: Colors.pink.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorPink,
                      ),
                      ColorOption(
                        colorHex: Colors.red.withOpacity(0.3).toHex(),
                        name: AppFlowyEditorLocalizations
                            .current.backgroundColorRed,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        editorState: editorState,
        scrollController: scrollController,
        style: FloatingToolbarStyle(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            toolbarActiveColor: Theme.of(context).colorScheme.onSurfaceVariant),
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
