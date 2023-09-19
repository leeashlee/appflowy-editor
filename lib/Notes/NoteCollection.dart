// ignore_for_file: file_names

import 'package:noel_notes/Notes/NoteEntry.dart';
import 'dart:developer' as developer;

class NoteCollection implements NoteEntry {
  String name;
  List<NoteEntry> notes = [];
  NoteEntry? curr;
  Comparator? comparator;

  NoteCollection(this.name, [NoteEntry? initial, bool withFocus = false]) {
    if (initial != null) {
      developer
          .log("starting NoteCollection with $initial and focus = $withFocus");
      notes.add(initial);
      curr = (withFocus ? initial : null);
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
    _onWrite();
  }

  void removeEntry(NoteEntry old) {
    int i = notes.indexOf(old);
    if (i == -1) {
      return;
    } else if (i == _getCurrIndex()) {
      throw Exception("cant remove the Entry that your currently editing");
    }
    notes.remove(old);
    _onWrite();
  }

  @override
  NoteEntry? getCurr() {
    return (curr != null) ? curr!.getCurr() : null; // be recursive
  }

  @override
  void setName(String name) {
    this.name = name;
  }

  int _getCurrIndex() {
    if (curr == null) {
      return -1;
    } else {
      return notes.indexOf(curr!);
    }
  }

  void setCurr(NoteEntry? newCurr) {
    developer.log("$name: setCurr: from $curr to $newCurr");
    if (getCurr() is NoteCollection) {
      getCurr()!.looseFocus();
    }
    curr = newCurr;
    _onWrite();
  }

  void switchFocus(NoteEntry noteEntry) {
    setCurr(noteEntry);
  }

  @override
  void looseFocus() {
    developer.log("$name: looseFocus: $curr");
    setCurr(null);
  }

  int getLength() {
    return notes.length;
  }

  void sortOnce(Comparator comparator) {
    notes.sort(comparator);
  }

  void keepSorted(Comparator comparator) {
    this.comparator = comparator;
    sortOnce(comparator);
  }

  void _onWrite() {
    if (comparator != null) {
      sortOnce(comparator!);
    }
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
