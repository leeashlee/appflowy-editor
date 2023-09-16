import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:developer' as developer;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final myCollectionController = TextEditingController();
  final myNoteController = TextEditingController();

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
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myCollectionController.dispose();
    super.dispose();
  }

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
        title: Text(notes.getCurr()!.getName()),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 70),
        child: _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Create a new note?'),
            content: TextField(
              autofocus: true,
              controller: myNoteController,
              decoration: const InputDecoration(
                label: Text('Note Name:'),
                border: OutlineInputBorder(),
                hintText: 'Untitled',
                icon: Icon(Icons.book_outlined),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: _addNote,
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        tooltip: 'Add Notes',
        child: const Icon(Icons.note_add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    var children = [
      // Saved Notes
      _buildSeparator(context, 'Your Saved Notes 📝'),
    ];
    developer.log("Notes length: ${notes.getLength()}");

    children.addAll(buildNotes(context, notes));

    children.addAll([
      // Export Notes
      _buildSeparator(context, 'Export Your Note 📂'),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          alignment: Alignment.centerLeft,
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          _exportFile(
            (notes.getCurr() as NoteFile).getBody(),
            ExportFileType.markdown,
          );
        },
        icon: const Icon(Icons.file_download),
        label: const Text('Export to Markdown'),
      ),

      const SizedBox(height: 4),

      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          alignment: Alignment.centerLeft,
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          _exportFile(
            (notes.getCurr() as NoteFile).getBody(),
            ExportFileType.html,
          );
        },
        icon: const Icon(Icons.html),
        label: const Text('Export to HTML'),
      ),

      Divider(
        color: Theme.of(context).colorScheme.outline,
      ),
      // Import Notes
      _buildSeparator(context, 'Import a New Note 📁'),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          alignment: Alignment.centerLeft,
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          _importFile(ExportFileType.markdown);
        },
        icon: const Icon(Icons.file_upload),
        label: const Text('Import From Markdown'),
      ),

      Divider(
        color: Theme.of(context).colorScheme.outline,
      ),

      // Settings
      _buildSeparator(context, 'Preferences ⚙️'),

      //Theme
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          alignment: Alignment.centerLeft,
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),
        onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        icon: const Icon(Icons.brightness_6),
        label: const Text('Change Theme'),
      ),

      const SizedBox(height: 4),

      //Create folder button
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          alignment: Alignment.centerLeft,
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Create a new note collection?'),
            content: TextField(
              autofocus: true,
              controller: myCollectionController,
              decoration: const InputDecoration(
                label: Text('Note Collection Name:'),
                border: OutlineInputBorder(),
                hintText: 'My Notes',
                icon: Icon(Icons.book_outlined),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: _createNoteCollection,
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        icon: const Icon(Icons.book),
        label: const Text('Create a new note collection'),
      ),
    ]);

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: children,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return _widgetBuilder(context);
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
          TextButton(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
            onPressed: () {
              developer.log("Button: switching to $i");
              _switchFile(i);
            },
            child: Text(
              prependage + (notes.getEntry(i) as NoteFile).getName(),
            ),
          ),
        );
      } else if (currNotes.getEntry(i) is NoteCollection) {
        retVal.add(
          ExpansionTile(
            initiallyExpanded: true,
            expandedAlignment: Alignment.centerLeft,
            title: Column(
              children: [
                Text(currNotes.getEntry(i).getName()),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    alignment: Alignment.centerLeft,
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    _addNote(currNotes.getEntry(i) as NoteCollection);
                  },
                  icon: const Icon(Icons.note_add),
                  label: const Text('Add a new note'),
                ),
              ],
            ),
            children: buildNotes(
              context,
              (currNotes.getEntry(i) as NoteCollection),
            ),
          ),
          /*_buildSeparator(context, currNotes.getEntry(i).getName()),*/
        );
        /*retVal.addAll(
          buildNotes(
            context,
            (currNotes.getEntry(i) as NoteCollection),
          ),
        );*/
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

  void _addNote([NoteCollection? into]) {
    // if into is null use the root
    into = (into != null) ? into : notes;
    setState(() {
      if(myNoteController.text == ''){
        into!.addEntry(NoteFile("Untitled", EditorState.blank()));
      developer.log(
        jsonEncode(into.toJson()),
      );
      } else {
        into!.addEntry(NoteFile(myNoteController.text, EditorState.blank()));
      developer.log(
        jsonEncode(into.toJson()),
      );
      }
      myNoteController.clear();
      Navigator.pop(context, 'OK');
    });
  }

  void _createNoteCollection() {
    setState(() {
      String title = myCollectionController.text;
      if (title == "") {
        title = "Untitled";
      }
      notes.addEntry(NoteCollection(title));
      myCollectionController.clear();
      Navigator.pop(context, 'OK');
    });
      myCollectionController.clear();
      Navigator.pop(context, 'OK');
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
