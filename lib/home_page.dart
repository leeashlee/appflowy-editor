import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:encrypt/encrypt.dart' as Crypto;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'appwrite/database_api.dart';
import 'model/settings/manager.dart';
import 'model/notes/note_file.dart';
import 'model/notes/NoteFolder.dart';
import 'model/notes/NoteEntry.dart';
import 'component/alert_dialog.dart';
import 'component/custom_app_bar.dart';
import 'component/editor/editor.dart';
import 'component/icons/unicon_icons.dart';

enum ExportFileType {
  markdown,
  html,
}

enum SyncTimer {
  local(milliseconds: 500),
  remote(seconds: 5);

  const SyncTimer({this.milliseconds = 0, this.seconds = 0});

  final int milliseconds;
  final int seconds;
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
  LocalStorage storage;
  SettingsManager settings;

  HomePage(this.storage, this.settings, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<SyncTimer, Timer> syncTimers = {};
  late NoteFolder notes;
  late WidgetBuilder _widgetBuilder;

  @override
  void dispose() {
    syncTimers.forEach((k, v) {
      v.cancel(); // stop all pending syncs
      doSync(k); // do one last sync
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initNotes();
    initTimers();
    _loadEditor(context, false);
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadEditor(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: PlatformExtension.isDesktopOrWeb,
      drawer: _buildDrawer(context),
      appBar: CustomAppBar(
        notes.getCurrNoteFile()!.getName(),
        notes.getCurrNoteFolder().getName(),
        (input) {
          setState(() {
            notes.getCurrNoteFile()!.setName(input);
          });
        },
        widget.settings,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 70),
        child: _widgetBuilder(context),
      ),
      //endlessly load
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => CustomAlertDialog(
            AlertType.newFile,
            (String? input) {
              NoteFile newNote = addNote(input ?? "Untitled");
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
            builder: (BuildContext context) =>
                CustomAlertDialog(AlertType.newFile, (input) {
              addNote(input!);
            }),
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
          builder: (BuildContext context) => CustomAlertDialog(
            AlertType.newCollec,
            (input) {
              setState(() {
                notes.addEntry(NoteFolder(input!));
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

  List<Widget> buildNotes(
    BuildContext context,
    NoteFolder currNotes, [
    List<NoteFolder>? parents,
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
                    builder: (BuildContext context) =>
                        CustomAlertDialog(AlertType.renameFile, (input) {
                      setState(
                        () {
                          currI.setName(input!);
                        },
                      );
                    }),
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
                    builder: (context) =>
                        CustomAlertDialog(AlertType.delFile, (input) {
                      setState(
                        () => removeNote(currI, currNotes),
                      );
                    }),
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
                    builder: (BuildContext context) =>
                        CustomAlertDialog(AlertType.renameFile, (input) {
                      setState(
                        () {
                          currI.setName(input!);
                        },
                      );
                    }),
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
                  //alignment: Alignment.centerLeft,
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
                child: Column(
                  children: [
                    Text(
                      currI.getName(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      currI.getStyledEditedTime(),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (currI is NoteFolder) {
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
                    builder: (BuildContext context) =>
                        CustomAlertDialog(AlertType.newFile, (input) {
                      addNote(input!, currI);
                    }),
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

  void _loadEditor(BuildContext context, bool notifyState) {
    void exec() {
      _widgetBuilder = (context) => Editor(
            editorState: notes.getCurrNoteFile()!.getBody(),
            onEditorStateChange: (editorState) {
              (notes.getCurrNoteFile() as NoteFile).setBody(editorState);
            },
          );
    }

    if (notifyState) {
      setState(exec);
    } else {
      exec();
    }
  }

  void sorting() {
    notes.keepSorted((a, b) {
      int res = boolToInt(b is NoteFolder) - boolToInt(a is NoteFolder);
      return res;
    });
  }

  // note stuff
  NoteFile addNote(String input, [NoteFolder? into]) {
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

  void removeNote(NoteEntry old, [NoteFolder? into]) {
    into = (into != null) ? into : notes;
    setState(
      () {
        into!.removeEntry(old);
      },
    );
  }

  void switchNote(List<NoteFolder> parents, NoteFile file) {
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
      _loadEditor(context, true);
    }
  }

  void doSync(SyncTimer timer) {
    switch (timer) {
      case SyncTimer.local:
        widget.storage.setItem("notes", notes);
        widget.storage.setItem("settings", widget.settings.toJson());
        break;
      case SyncTimer.remote:
        //TODO: extract into another class (maybe UploadManager, ...)

        // seedphrase as password
        String seed = widget.settings.getValue<String>(Settings.seedphrase);
        String salt = widget.settings.getValue<String>(Settings.salt);
        if (seed == "") break; // need to wait for seedphrase
        Crypto.Key key = Crypto.Key.fromUtf8(seed).stretch(
          32,
          salt: Crypto.Key.fromBase64(salt).bytes,
        );

        // initialization vector
        Crypto.IV iv = Crypto.IV.fromLength(16);
        log(key.base64);
        // encrypt with key and output as base64 encoded
        String data =
            Crypto.Encrypter(Crypto.AES(key, mode: Crypto.AESMode.gcm))
                .encrypt(jsonEncode(notes.toJson()), iv: iv)
                .base64;
        data += "|${iv.base64}"; // append IV
        log("Encrypted data: $data");
        // DECRYPTION EXAMPLE
        // Crypto.Encrypter(
        //   Crypto.AES(
        //       Crypto.Key.fromUtf8(seed).stretch(
        //         32,
        //         salt: Crypto.Key.fromBase64(salt).bytes,
        //       ),
        //       mode: Crypto.AESMode.gcm),
        // ).decrypt64(
        //   data.split("|")[0],
        //   iv: Crypto.IV.fromBase64(
        //     data.split("|")[1],
        //   ),
        // );
        //final DatabaseAPI db = context.read<DatabaseAPI>();
        //db.updateNoteEntry(data);
        break;
      default:
    }
  }

  void initNotes() {
    Map? lclNotes = widget.storage.getItem("notes");

    if (lclNotes == null) {
      notes = NoteFolder(
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
      notes = NoteFolder.fromJson(lclNotes, true) as NoteFolder;
    }
  }

  void initTimers() {
    // read the values from all timers and initialize them
    for (SyncTimer e in SyncTimer.values) {
      syncTimers[e] = Timer.periodic(
        Duration(seconds: e.seconds, milliseconds: e.milliseconds),
        (timer) {
          doSync(e);
        },
      );
    }
  }
}

int boolToInt(bool input) {
  return input ? 1 : 0;
}
