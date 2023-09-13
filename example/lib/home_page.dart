import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/customize_theme_for_editor.dart';
import 'package:example/pages/editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

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

class Note {
  String title = "UwU";
  EditorState body = EditorState.blank();
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var notes = <Note>[];
  late WidgetBuilder _widgetBuilder;
  late EditorState _editorState;
  late Future<String> _jsonString;

  @override
  void initState() {
    super.initState();

    _jsonString = rootBundle.loadString('assets/example.json');

    _widgetBuilder = (context) => Editor(
          jsonString: _jsonString,
          onEditorStateChange: (editorState) {
            _editorState = editorState;
          },
        );
  }

  @override
  void reassemble() {
    super.reassemble();

    _widgetBuilder = (context) => Editor(
          jsonString: _jsonString,
          onEditorStateChange: (editorState) {
            _editorState = editorState;
            _jsonString = Future.value(
              jsonEncode(_editorState.document.toJson()),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: PlatformExtension.isDesktopOrWeb,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        surfaceTintColor: Colors.transparent,
        title: const Text('Note Taking App'),
      ),
      body: SafeArea(child: _buildBody(context)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add Notes',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    var children = [
      DrawerHeader(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Image.asset(
          'assets/images/icon.png',
          fit: BoxFit.fill,
        ),
      ),

      // saved notes
      _buildSeparator(context, 'Your Saved Notes'),
    ];
    for (final note in notes) {
      children.add(_buildListTile(context, 'Note 1 example', () {
        _switchFile(_editorState, ExportFileType.markdown);
      }));
    }

    children.addAll([
      // Encoder Demo
      _buildSeparator(context, 'Export Your Note'),
      _buildListTile(context, 'Export to Markdown', () {
        _exportFile(_editorState, ExportFileType.markdown);
      }),

      _buildListTile(context, 'Export to HTML', () {
        _exportFile(_editorState, ExportFileType.html);
      }),

      // Decoder Demo
      _buildSeparator(context, 'Import a New Note'),
      _buildListTile(context, 'Import From Markdown', () {
        _importFile(ExportFileType.markdown);
      }),
    ]);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _widgetBuilder(context);
  }

  Widget _buildListTile(
    BuildContext context,
    String text,
    VoidCallback? onTap,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 16),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.deepPurple,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }

  Widget _buildSeparator(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _loadEditor(
    BuildContext context,
    Future<String> jsonString,
  ) async {
    final completer = Completer<void>();
    _jsonString = jsonString;
    setState(
      () {
        _widgetBuilder = (context) => Editor(
              jsonString: _jsonString,
              onEditorStateChange: (editorState) {
                _editorState = editorState;
              },
            );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      completer.complete();
    });
    return completer.future;
  }

  void _addNote() {
    final jsonString = Future<String>.value(
      jsonEncode(
        EditorState.blank(withInitialText: true).document.toJson(),
      ).toString(),
    );
    notes.add(Note());
    _loadEditor(context, jsonString);
  }

  void _exportFile(EditorState editorState, ExportFileType fileType) async {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This document is saved to the $path'),
            ),
          );
        }
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

  void _switchFile(
    EditorState editorState,
    ExportFileType fileType,
  ) {
    _exportFile(editorState, fileType);
    _importFile(fileType);
  }

  void _importFile(ExportFileType fileType) async {
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
      final bytes = result?.files.first.bytes;
      if (bytes == null) {
        return;
      }
      plainText = const Utf8Decoder().convert(bytes);
    }

    var jsonString = '';
    switch (fileType) {
      case ExportFileType.markdown:
        jsonString = jsonEncode(markdownToDocument(plainText).toJson());
        break;
      case ExportFileType.html:
        throw UnimplementedError();
    }

    if (mounted) {
      _loadEditor(context, Future<String>.value(jsonString));
    }
  }
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => r.nextInt(33) + 89),
  );
}
