import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:developer' as developer;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/Notes/NoteCollection.dart';
import 'package:noel_notes/Notes/NoteEntry.dart';
import 'package:noel_notes/main.dart';
import 'package:noel_notes/pages/editor.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var notes = NoteCollection(
    "My Notes",
    NoteFile(
      "Untitled",
      EditorState.blank(),
    ),
    true,
  );
  late WidgetBuilder _widgetBuilder;

  @override
  void initState() {
    super.initState();

    _widgetBuilder = (context) => Editor(
          editorState: (notes.getCurr() as NoteFile).getBody(),
          onEditorStateChange: (editorState) {
            (notes.getCurr() as NoteFile).setBody(editorState);
          },
        );
  }

  @override
  void reassemble() {
    super.reassemble();

    _widgetBuilder = (context) => Editor(
          editorState: (notes.getCurr() as NoteFile).getBody(),
          onEditorStateChange: (editorState) {
            (notes.getCurr() as NoteFile).setBody(editorState);
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
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _addNote,
            tooltip: 'Add Notes',
            child: const Icon(Icons.note_add),
          ),
          const SizedBox(width: 4),
          FloatingActionButton(
            onPressed: _createNoteCollection,
            tooltip: 'Create Note Collection',
            child: const Icon(Icons.book),
          ),
          const SizedBox(width: 4),
          FloatingActionButton(
            onPressed: _changeTheme,
            tooltip: 'change theme',
            child: const Icon(Icons.brightness_6),
          ),
        ],
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
      _buildSeparator(context, 'Your Saved Notes 📝'),
    ];
    developer.log("Notes length: ${notes.getLength()}");

    children.addAll(buildNotes(context, notes));

    children.addAll([
      Divider(
        color: Theme.of(context).colorScheme.outline,
        indent: 16,
        endIndent: 16,
      ),
      // Encoder Demo
      _buildSeparator(context, 'Export Your Note 📂'),
      _buildListTile(context, 'Export to Markdown', () {
        _exportFile(
          (notes.getCurr() as NoteFile).getBody(),
          ExportFileType.markdown,
        );
      }),

      _buildListTile(context, 'Export to HTML', () {
        _exportFile(
          (notes.getCurr() as NoteFile).getBody(),
          ExportFileType.html,
        );
      }),

      Divider(
        color: Theme.of(context).colorScheme.outline,
        indent: 16,
        endIndent: 16,
      ),
      // Decoder Demo
      _buildSeparator(context, 'Import a New Note 📁'),
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
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }

  List<Widget> buildNotes(
    BuildContext context,
    NoteCollection currNotes, [
    String prependage = "",
  ]) {
    List<Widget> retVal = [];
    for (int i = 0; i < currNotes.getLength(); i++) {
      developer.log("Building ListTile No. $i");
      if (currNotes.getEntry(i) is NoteFile) {
        retVal.add(
          _buildListTile(
              context, prependage + (notes.getEntry(i) as NoteFile).getName(),
              () {
            developer.log("Button: switching to $i");
            _switchFile(i);
          }),
        );
      } else if (currNotes.getEntry(i) is NoteCollection) {
        retVal.add(_buildSeparator(context, currNotes.getEntry(i).getName()));
        retVal.addAll(
          buildNotes(
            context,
            (currNotes.getEntry(i) as NoteCollection),
          ),
        );
      }
    }
    return retVal;
  }

  Widget _buildSeparator(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
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
              editorState: (notes.getCurr() as NoteFile).getBody(),
              onEditorStateChange: (editorState) {
                (notes.getCurr() as NoteFile).setBody(editorState);
              },
            );
      },
    );
  }

  void _addNote() {
    setState(() {
      notes.addEntry(NoteFile("New unnamed Note", EditorState.blank()));
      developer.log(jsonEncode(notes.toJson()));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You added a new note.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      ),
    );
  }

  void _createNoteCollection() {
    setState(() {
      notes.addEntry(
        NoteCollection(
          "My Notes",
          NoteFile(
            "Untitled",
            EditorState.blank(),
          ),
          true,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You created a note collection.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        ),
      );
    });
  }

  void _changeTheme() {
    if (Theme.of(context).brightness == Brightness.dark) {
      
    } else {

    }
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
    int neww,
  ) {
    setState(() {
      //save old body
      notes.setCurr(neww);
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
