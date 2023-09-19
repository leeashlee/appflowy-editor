import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:noel_notes/unicon_icons.dart';

import '../../Notes/NoteCollection.dart';

import 'dart:developer' as dev;

import '../../Notes/NoteEntry.dart';
import '../custom_alert_dialog.dart';

List<Widget> buildNotes(
  BuildContext context,
  NoteCollection currNotes,
  void Function(void Function()) setState,
  void Function(String input, [NoteCollection? into]) addNote, // FIXME
  void Function(List<NoteCollection> parents, NoteFile file) switchNote, // FIXME
  NoteCollection notes, [
  List<NoteCollection>? parents,
]) {
  final myNoteController = TextEditingController();
  parents = (parents != null) ? List.from(parents) : [];
  parents.add(currNotes);
  List<Widget> retVal = [];
  dev.log(
    "buildNotes: ${jsonEncode(parents.map((e) => e.getName()).toList())}, $currNotes,",
  );
  for (int i = 0; i < currNotes.getLength(); i++) {
    NoteEntry currI = currNotes.getEntry(i);
    dev.log("buildNotes: Building ListTile No. $i");
    if (currI is NoteFile) {
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
                    content: const Text("The note can't be restored later."),
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
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context, 'OK');
                            notes.removeEntry(currI);
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
                    content: const Text("It won't be undone."),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context, 'OK');
                            notes.removeEntry(currI);
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
            //TODO Highlighting a note you're currently editing
            child: TextButton(
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
              ),
              onPressed: () {
                dev.log("buildNotes: onSwitchNote: switching to $i");
                switchNote(parents!, currI);
                dev.log(
                  "buildNote: onSwitchNote: switched to $i -> ${notes.getCurr()}",
                );
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
          initiallyExpanded: false,
          expandedAlignment: Alignment.centerLeft,
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
          children: buildNotes(
            context,
            currI,
            setState,
            addNote,
            switchNote,
            notes,
            parents,
          ),
        ),
      );
    }
  }
  return retVal;
}
