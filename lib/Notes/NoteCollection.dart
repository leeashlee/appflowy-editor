// ignore_for_file: file_names

import 'package:noel_notes/Notes/NoteEntry.dart';
import 'dart:developer' as developer;

class NoteCollection implements NoteEntry {
  String name;
  List<NoteEntry> notes = [];
  int curr = -1;
  NoteCollection(this.name, [NoteEntry? initial, bool withFocus = false]) {
    if (initial != null) {
      developer
          .log("starting NoteCollection with $initial and focus = $withFocus");
      notes.add(initial);
      curr = (withFocus ? 1 : 0) - 1;
    }
  }

  NoteEntry getEntry(int index) {
    return notes[index];
  }

  @override
  String getName() {
    return name;
  }

  void addEntry(NoteEntry neww) {
    developer.log("New entry: ${neww.getName()}");
    notes.add(neww);
  }

  void removeEntry(NoteEntry old) {
    notes.remove(old);
  }

  Iterator<NoteEntry> getIter() {
    return notes.iterator;
  }

  @override
  NoteEntry? getCurr() {
    developer.log("$name: getCurr: $curr");
    return (curr != -1) ? getEntry(curr).getCurr() : null;
  }

  void setCurr(int newCurr) {
    developer.log("$name: setCurr: from $curr to $newCurr");
    getCurr()!.looseFocus();
    curr = newCurr;
  }

  @override
  void looseFocus() {
    developer.log("$name: getCurr: $curr");
    setCurr(-1);
  }

  num getLength() {
    return notes.length;
  }

  @override
  Map<String, Object> toJson() {
    return {
      "name": name,
      "body": notes.map((x) {
        return x.toJson();
      }).toList(),
    };
  }
}