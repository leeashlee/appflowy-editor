import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class Editor extends StatelessWidget {
  const Editor({
    super.key,
    required this.editorState,
    required this.onEditorStateChange,
    this.editorStyle,
  });

  final EditorState editorState;
  final EditorStyle? editorStyle;
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
          buildTextColorItem(),
          buildHighlightColorItem(),
          ...textDirectionItems,
          ...alignmentItems,
        ],
        editorState: editorState,
        scrollController: scrollController,
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
      editorStyle: const EditorStyle.mobile(),
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
    );
  }
}
