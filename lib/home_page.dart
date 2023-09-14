import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:developer' as developer;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:NoelNotes/pages/customize_theme_for_editor.dart';
import 'package:NoelNotes/pages/editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  String title;
  EditorState body;

  Note(this.title, this.body);

  Map toJson() {
    return {"title": title, "body": body.document.toJson()};
  }

  String getTitle() {
    return title;
  }

  void setTitle(String title) {
    this.title = title;
  }

  EditorState getBody() {
    return body;
  }

  void setBody(EditorState body) {
    this.body = body;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var notes = <Note>[
    Note(
      "Untitled",
      EditorState.blank(
          // withInitialText: false,
          ),
    ),
  ];
  var currNote = 0;
  late WidgetBuilder _widgetBuilder;

  @override
  void initState() {
    super.initState();

    _widgetBuilder = (context) => Editor(
          editorState: notes[currNote].body,
          onEditorStateChange: (editorState) {
            notes[currNote].setBody(editorState);
          },
        );
  }

  @override
  void reassemble() {
    super.reassemble();

    _widgetBuilder = (context) => Editor(
          editorState: notes[currNote].getBody(),
          onEditorStateChange: (editorState) {
            notes[currNote].setBody(editorState);
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
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 70),
        child: _buildBody(context),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _addNote,
            tooltip: 'Add Notes',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            onPressed: _addNote,
            tooltip: 'Save Notes',
            child: const Icon(Icons.save),
          ),
        ]
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
    developer.log("Notes length: ${notes.length}");
    for (int i = 0; i < notes.length; i++) {
      developer.log("Building ListTile No. $i");
      children.add(
        _buildListTile(context, notes[i].getTitle(), () {
          developer.log("switching from $currNote to $i");
          developer.log("${notes[currNote].getBody()}");
          _switchFile(
            notes[currNote].getBody(),
            ExportFileType.markdown,
            currNote,
            i,
          );
        }),
      );
    }

    children.addAll([
      // Encoder Demo
      _buildSeparator(context, 'Export Your Note'),
      _buildListTile(context, 'Export to Markdown', () {
        _exportFile(notes[currNote].getBody(), ExportFileType.markdown);
      }),

      _buildListTile(context, 'Export to HTML', () {
        _exportFile(notes[currNote].getBody(), ExportFileType.html);
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

  void _loadEditor(BuildContext context) {
    setState(
      () {
        _widgetBuilder = (context) => Editor(
              editorState: notes[currNote].getBody(),
              onEditorStateChange: (editorState) {
                notes[currNote].setBody(editorState);
              },
            );
      },
    );
  }

  void _addNote() {
    setState(() {
      notes.add(Note("Note No. ${currNote++}", EditorState.blank()));
      developer.log(jsonEncode(notes));
    });
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
    EditorState oldEditorState,
    ExportFileType fileType,
    int old,
    int neww,
  ) {
    setState(() {
      //save old body
      notes[old].setBody(oldEditorState);
      // switch to neww
      currNote = neww;
      developer
          .log("Old State: ${jsonEncode(oldEditorState.document.toJson())}");
      developer.log("Old: $old");
      developer.log("neww: $neww");
    });
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
      final bytes = result?.files.single.bytes;
      if (bytes == null) {
        return;
      }
      plainText = const Utf8Decoder().convert(bytes);
    }

    switch (fileType) {
      case ExportFileType.markdown:
        notes.add(
          Note(
            "Imported document \"called ${result?.files.single.name}\"",
            EditorState(document: markdownToDocument(plainText)),
          ),
        );

        break;
      case ExportFileType.html:
        throw UnimplementedError();
    }

    if (mounted) {
      _loadEditor(context);
    }
  }
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => r.nextInt(33) + 89),
  );
}
