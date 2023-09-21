// ignore: unused_import
import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'desktop_editor.dart';
import 'mobile_editor.dart';

class Editor extends StatelessWidget {
  const Editor({
    super.key,
    required this.editorState,
    required this.onEditorStateChange,
    this.editorStyle,
    this.textDirection = TextDirection.ltr,
  });

  final EditorState editorState;
  final EditorStyle? editorStyle;
  final void Function(EditorState editorState) onEditorStateChange;

  final TextDirection textDirection;

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

    return Container(
      color: Colors.white,
      child: mobileOrDesktop(),
    );
  }

  Widget mobileOrDesktop() {
    if (PlatformExtension.isMobile) {
      return MobileEditor(
        editorState: editorState,
      );
    } else {
      return DesktopEditor(
        editorState: editorState,
        textDirection: textDirection,
      );
    }
  }
}
