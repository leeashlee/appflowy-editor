import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noel_notes/Notes/NoteCollection.dart';
import 'package:noel_notes/main.dart';

import 'dart:developer' as dev;

import '../../Notes/NoteEntry.dart';
import '../../unicon_icons.dart';
import '../custom_alert_dialog.dart';
import 'build_notes.dart';
import 'file_utils.dart';

class CustomDrawer extends StatefulWidget {
  final String label;
  final NoteCollection notes;
  final Function(String input) onEnter;
  final void Function(String input, [NoteCollection? into]) addNote; // FIXME
  final void Function(List<NoteCollection> parents, NoteFile file)
      switchNote; // FIXME

  const CustomDrawer(
      this.label, this.notes, this.onEnter, this.addNote, this.switchNote,
      {super.key,});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    var children = [
      _buildSeparator(context, 'Your Saved Notes 📝'),
    ];
    dev.log("_buildDrawer: Notes length: ${widget.notes.getLength()}");

    //children.addAll(buildNotes(context, notes));

    children.addAll([
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
                widget.notes.addEntry(NoteCollection(input));
                throw UnimplementedError();
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
          exportFile(
            (widget.notes.getCurr() as NoteFile).getBody(),
            ExportFileType.markdown,
          );
        },
        icon: const Icon(Unicon.export_icon),
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
          exportFile(
            (widget.notes.getCurr() as NoteFile).getBody(),
            ExportFileType.html,
          );
        },
        icon: const Icon(Unicon.export_icon),
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
          importFile(ExportFileType.markdown, widget.notes);
        },
        icon: const Icon(Unicon.import_icon),
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
        onPressed: () => {
          context.read<ThemeCubit>().toggleTheme(),
          Navigator.pop(context, 'OK'),
        },
        icon: const Icon(Unicon.brightness_half),
        label: const Text('Change Theme'),
      ),
    ]);
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: children,
      ),
    );
  }

  Widget buildNotesList(BuildContext context, NoteCollection currNotes) {
    return ExpansionTile(
      textColor: Theme.of(context).colorScheme.primary,
      tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      initiallyExpanded: true,
      expandedAlignment: Alignment.centerLeft,
      title: Text(currNotes.getName()),
      children: buildNotes(
        context,
        currNotes,
        setState,
        widget.addNote,
        widget.switchNote,
        widget.notes,
      ),
    );
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
}
