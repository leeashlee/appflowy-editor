// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:developer' as dev;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:noel_notes/Notes/NoteCollection.dart';
import 'package:noel_notes/Notes/NoteEntry.dart';
import 'package:noel_notes/component/custom_alert_dialog.dart';
import 'package:noel_notes/component/custom_app_bar.dart';
import 'package:noel_notes/component/editor/editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

//TODO Adding an account with username and password that keeps your files on the server
//TODO Encryption
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

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final Future<SharedPreferences> prefs =
      SharedPreferences.getInstance().onError((error, stackTrace) {
    print("$error, $stackTrace");
    dev.log("$error, $stackTrace");
    return Future.error(error!);
  }).timeout(const Duration(seconds: 10));

  LocalStorage storage;

  HomePage(this.storage, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? syncTimer;
  final myNoteController = TextEditingController();
  // ignore: unnecessary_new
  LocalStorage storage = new LocalStorage("storage");

  late NoteCollection notes;
  late WidgetBuilder _widgetBuilder;

  @override
  void dispose() {
    syncTimer?.cancel();
    doSync();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    notes = initNotes();

    syncTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        doSync();
      },
    );

    _widgetBuilder = (context) => Editor(
          editorState: (notes.getCurrNoteFile() as NoteFile).getBody(),
          onEditorStateChange: (editorState) {
            (notes.getCurrNoteFile() as NoteFile).setBody(editorState);
          },
        );
  }

  @override
  void reassemble() {
    super.reassemble();

    _widgetBuilder = (context) => Editor(
          editorState: (notes.getCurrNoteFile() as NoteFile).getBody(),
          onEditorStateChange: (editorState) {
            (notes.getCurrNoteFile() as NoteFile).setBody(editorState);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: PlatformExtension.isDesktopOrWeb,
      drawer: _buildDrawer(context),
      appBar: CustomAppBar(
        notes.getCurrNoteFile()!.getName(),
        notes.getCurrNoteCollection().getName(),
        (input) {
          setState(() {
            notes.getCurrNoteFile()!.setName(input);
          });
        },
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 70),
        child: _buildBody(context),
      ),
      //endlessly load
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => customAlertDialog(
            context,
            'Create a new note?',
            'Note Name:',
            'Untitled',
            const Icon(Unicon.edit_alt),
            (String input) {
              NoteFile newNote = addNote(input);
              switchNote([notes], newNote);
            },
          ),
        ),
        tooltip: 'Add Notes',
        child: const Icon(Unicon.file_medical),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    var children = [
      const SizedBox(
        height: 25,
      ),
      _buildSeparator(context, 'Your Saved Notes 📝'),
    ];

    children.addAll([
      ExpansionTile(
        textColor: Theme.of(context).colorScheme.primary,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        initiallyExpanded: true,
        expandedAlignment: Alignment.centerLeft,
        title: Text(notes.getName()),
        trailing: IconButton(
          iconSize: 20.0,
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => customAlertDialog(
              context,
              'Create a new note?',
              'Note Name:',
              'Untitled',
              const Icon(Unicon.edit_alt),
              (String input) {
                addNote(input);
              },
            ),
          ),
          icon: const Icon(Unicon.file_medical),
        ),
        children: (buildNotes(context, notes)),
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
          builder: (BuildContext context) => customAlertDialog(
            context,
            'Create a new note collection?',
            'Note Collection Name:',
            'My Notes',
            const Icon(Unicon.book_open),
            (String input) {
              setState(() {
                notes.addEntry(NoteCollection(input));
                sorting();
              });
            },
          ),
        ),
        icon: const Icon(Unicon.books),
        label: const Text('Create a new note collection'),
      ),

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
            (notes.getCurrNoteFile() as NoteFile).getBody(),
            ExportFileType.markdown,
          );
        },
        icon: const Icon(Unicon.export_icon),
        label: const Text('Export to Markdown'),
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
        icon: const Icon(Unicon.import_icon),
        label: const Text('Import From Markdown'),
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
    List<NoteCollection>? parents,
  ]) {
    parents = (parents != null) ? List.from(parents) : [];
    parents.add(currNotes);
    List<Widget> retVal = [];
    for (int i = 0; i < currNotes.getLength(); i++) {
      NoteEntry currI = currNotes.getEntry(i);
      if (currI is NoteFile) {
        Color prim = Theme.of(context).colorScheme.primary;
        Color sec = Colors.transparent;
        Color bg = (currI == notes.getCurrNoteFile()) ? prim : sec;
        Color fg = (currI == notes.getCurrNoteFile())
            ? Theme.of(context).colorScheme.onPrimary
            : prim;
        retVal.add(
          Slidable(
            endActionPane: ActionPane(
              extentRatio: 1 / 2,
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  icon: Unicon.edit_alt,
                  onPressed: (context) => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => customAlertDialog(
                      context,
                      'Rename the note?',
                      'Note Name:',
                      'Untitled',
                      const Icon(Unicon.edit_alt),
                      (input) {
                        setState(
                          () {
                            currI.setName(input);
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                SlidableAction(
                  borderRadius: BorderRadius.circular(4),
                  icon: Unicon.trash,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  onPressed: (context) => showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Do you wanna delete the note?'),
                      content: const Text("It can't be undone."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => {
                            Navigator.pop(context, 'Cancel'),
                            myNoteController.clear(),
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor:
                                Theme.of(context).colorScheme.onError,
                          ),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context, 'OK');
                              removeNote(currI, currNotes);
                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            startActionPane: ActionPane(
              extentRatio: 1 / 2,
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  icon: Unicon.edit_alt,
                  onPressed: (context) => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => customAlertDialog(
                      context,
                      'Rename the note?',
                      'Note Name:',
                      'Untitled',
                      const Icon(Unicon.edit_alt),
                      (input) {
                        setState(
                          () {
                            currI.setName(input);
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                SlidableAction(
                  borderRadius: BorderRadius.circular(4),
                  icon: Unicon.trash,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  onPressed: (context) => showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Do you wanna delete the note?'),
                      content: const Text("It can't be undone."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor:
                                Theme.of(context).colorScheme.onError,
                          ),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context, 'OK');
                              removeNote(currI, currNotes);
                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            child: SizedBox(
              width: 320,
              child: TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  foregroundColor: fg,
                  backgroundColor: bg,
                ),
                onPressed: () {
                  switchNote(parents!, currI);
                  Navigator.pop(context, "OK");
                },
                child: Text(
                  currI.getName(),
                ),
              ),
            ),
          ),
        );
      } else if (currI is NoteCollection) {
        retVal.add(
          ExpansionTile(
            textColor: Theme.of(context).colorScheme.primary,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            initiallyExpanded: currI.isInFocus(),
            expandedAlignment: Alignment.centerLeft,
            trailing: IconButton(
              color: Theme.of(context).colorScheme.error,
              onPressed: () => showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Do you wanna delete the collection?'),
                  content: const Text("It can't be undone."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context, 'OK');
                          removeNote(currI);
                        });
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Unicon.trash),
            ),
            title: Row(
              children: [
                Text(currI.getName()),
                const SizedBox(width: 4),
                IconButton(
                  iconSize: 20.0,
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => customAlertDialog(
                      context,
                      'Create a new note?',
                      'Note Name:',
                      'Untitled',
                      const Icon(Unicon.edit_alt),
                      (input) {
                        addNote(input, currI);
                      },
                    ),
                  ),
                  icon: const Icon(Unicon.file_medical),
                ),
              ],
            ),
            children: buildNotes(context, currI, parents),
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
              editorState: (notes.getCurrNoteFile() as NoteFile).getBody(),
              onEditorStateChange: (editorState) {
                (notes.getCurrNoteFile() as NoteFile).setBody(editorState);
              },
            );
      },
    );
  }

  void sorting() {
    notes.keepSorted((a, b) {
      int res = boolToInt(b is NoteCollection) - boolToInt(a is NoteCollection);
      return res;
    });
  }

  // note stuff
  NoteFile addNote(String input, [NoteCollection? into]) {
    NoteFile newNote = NoteFile(input, EditorState.blank());
    // if into is null use the root
    into = (into != null) ? into : notes;
    setState(
      () {
        into!.addEntry(newNote);
      },
    );
    return newNote;
  }

  void removeNote(NoteEntry old, [NoteCollection? into]) {
    into = (into != null) ? into : notes;
    setState(
      () {
        into!.removeEntry(old);
      },
    );
  }

  void switchNote(List<NoteCollection> parents, NoteFile file) {
    setState(() {
      // switch the focus recursively for all parents (propagate)
      for (var i = 0; i < parents.length - 1; i++) {
        parents[i].switchFocus(parents[i + 1]);
      }

      // the last parent is the parent of the file
      parents[parents.length - 1].switchFocus(file);
    });
  }

// file stuff
  void _exportFile(EditorState editorState, ExportFileType fileType) async {
    var result = '';

    switch (fileType) {
      case ExportFileType.markdown:
        result = documentToMarkdown(editorState.document);
        break;
      case ExportFileType.html:
        throw UnimplementedError();
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export isn`t available to mobile yet.'),
        ),
      );
      Navigator.pop(context, "OK");
      return null;
    }
    if (!kIsWeb) {
      final path = await FilePicker.platform.saveFile(
        fileName: '${notes.getCurrNoteFile()!.getName()}.${fileType.extension}',
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
        ..setAttribute(
          'download',
          '${notes.getCurrNoteFile()!.getName()}.${fileType.extension}',
        )
        ..click();
    }
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

  void doSync() {
    storage.setItem("notes", notes);
  }

  NoteCollection initNotes() {
    Map? lclNotes = storage.getItem("notes");

    if (lclNotes == null) {
      return NoteCollection(
        "My Notes",
        true,
        [
          NoteFile(
            "Untitled",
            EditorState.blank(),
          ),
        ],
      );
    } else {
      return NoteCollection.fromJson(lclNotes, true) as NoteCollection;
    }
  }
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => r.nextInt(33) + 89),
  );
}

int boolToInt(bool input) {
  return input ? 1 : 0;
}
