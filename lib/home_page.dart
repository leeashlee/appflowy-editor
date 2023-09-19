// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';

import 'dart:developer' as dev;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:noel_notes/Notes/NoteCollection.dart';
import 'package:noel_notes/Notes/NoteEntry.dart';
import 'package:noel_notes/component/appdrawer/appdrawer.dart';
import 'package:noel_notes/component/custom_alert_dialog.dart';
import 'package:noel_notes/component/custom_app_bar.dart';
import 'package:noel_notes/component/editor/editor.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/unicon_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO Adding an account with username and password that keeps your files on the server
//TODO Encryption

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferences? prefs =
      SharedPreferences.getInstance().onError((error, stackTrace) {
    dev.log("$error, $stackTrace");
    return Future.error(error!);
  }).unwrapOrNull<SharedPreferences>();

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
    super.dispose();
  }

  @override
  void initState() {
    dev.log("initState");

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
      appBar: CustomAppBar(
        notes.getCurr()!.getName(),
        notes.getName(),
        (input) {
          setState(() {
            notes.getCurr()!.setName(input);
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
              addNote(input);
            },
          ),
        ),
        tooltip: 'Add Notes',
        child: const Icon(Unicon.file_medical),
      ),
    );
  }

  //FIXME: can be put in another file
  Widget _buildDrawer(BuildContext context) {
    return CustomDrawer(
      "forgor",
      notes,
      (input) => print("idk"),
      addNote,
      switchNote,
    );
  }

  Widget _buildBody(BuildContext context) {
    return _widgetBuilder(context);
  }

  //TODO Learning how to make it a Reorderable List View

  //FIXME: can be put in another file

  /*void _loadEditor(BuildContext context) {
    setState(
      () {
        // FIXME: make a function for the Editor
        _widgetBuilder = (context) => Editor(
              editorState: (notes.getCurr() as NoteFile).getBody(),
              onEditorStateChange: (editorState) {
                (notes.getCurr() as NoteFile).setBody(editorState);
              },
            );
      },
    );
  }*/

  void sorting() {
    dev.log("sorting: sorter pressed");
    notes.keepSorted((a, b) {
      int res = boolToInt(b is NoteCollection) - boolToInt(a is NoteCollection);
      print("Sorter: ${a.toString()} vs ${b.toString()} == $res");
      return res;
    });
  }
  // note stuff
  void addNote(String input, [NoteCollection? into]) {
    // if into is null use the root
    into = (into != null) ? into : notes;
    setState(
      () {
        into!.addEntry(NoteFile(input, EditorState.blank()));
        dev.log(
          "addNote: ${jsonEncode(into.toJson())}",
        );
      },
    );
  }

  //FIXME: can be put in another file
  void switchNote(List<NoteCollection> parents, NoteFile file) {
    setState(() {
      dev.log(
        "switchNote: parents: ${jsonEncode(parents.map((e) => e.getName()).toList())}",
      );
      dev.log("switchNote: new: ${file.getName()}");
      // switch the focus recursively for all parents (propagate)
      for (var i = 0; i < parents.length - 1; i++) {
        parents[i].switchFocus(parents[i + 1]);
      }

      // the last parent is the parent of the file
      parents[parents.length - 1].switchFocus(file);
    });
    Navigator.pop(context, 'OK');
  }

// file stuff
  //FIXME: can be put in another file
}

//FIXME: can be put in another file
String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => r.nextInt(33) + 89),
  );
}

//FIXME: can be put in another file
int boolToInt(bool input) {
  return input ? 1 : 0;
}
