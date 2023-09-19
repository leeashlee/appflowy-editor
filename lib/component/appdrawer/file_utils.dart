import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:noel_notes/Notes/NoteCollection.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

import '../../Notes/NoteEntry.dart';

enum ExportFileType {
  markdown,
  html,
}

extension on ExportFileType {
  String get extension {
    switch (this) {
      case ExportFileType.markdown:
        return 'md';
      case ExportFileType.html:
        return 'html';
    }
  }
}

void exportFile(EditorState editorState, ExportFileType fileType) async {
  var result = '';

  switch (fileType) {
    case ExportFileType.markdown:
      result = documentToMarkdown(editorState.document);
      break;
    case ExportFileType.html:
      throw UnimplementedError();
  }

  if (!kIsWeb) {
    final path = await FilePicker.platform.saveFile(
      fileName: 'document.${fileType.extension}',
    );
    if (path != null) {
      await File(path).writeAsString(result);
      /* FIXME: figure out what that does
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This document is saved to the $path'),
          ),
        );
      }
      */
    }
  } else {
    final blob = html.Blob([result], 'text/plain', 'native');
    html.AnchorElement(
      href: html.Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute('download', 'document.${fileType.extension}')
      ..click();
  }
}

//FIXME: can be put in another file
void importFile(ExportFileType fileType, NoteCollection notes) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    allowedExtensions: [fileType.extension],
    type: FileType.custom,
  );
  var plainText = '';
  if (!kIsWeb) {
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }
    plainText = await File(path).readAsString();
  } else {
    final bytes = result?.files.single.bytes;
    if (bytes == null) {
      return;
    }
    plainText = const Utf8Decoder().convert(bytes);
  }

  switch (fileType) {
    case ExportFileType.markdown:
      notes.addEntry(
        NoteFile(
          "${result?.files.single.name}",
          EditorState(document: markdownToDocument(plainText)),
        ),
      );

      break;
    case ExportFileType.html:
      throw UnimplementedError();
  }
/* TODO: figure out what that does
  if (mounted) {
    _loadEditor(context);
  }*/
}
