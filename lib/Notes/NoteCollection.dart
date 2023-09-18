// ignore_for_file: file_names

import 'package:noel_notes/Notes/NoteEntry.dart';
import 'dart:developer' as developer;

class NoteCollection implements NoteEntry {
  String name;
  List<NoteEntry> notes = [];
  int curr = -1;
  Comparator? comparator;

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
    onChange();
  }

  void removeEntry(NoteEntry old) {
    int i = notes.indexOf(old);
    if (i == -1) {
      return;
    } else if (i < getCurrIndex()) {
      setCurr(getCurrIndex() - 1);
    } else if (i == getCurrIndex()) {
      throw Exception("cant remove the Entry that your currently editing");
    }
    notes.remove(old);
    onChange();
  }

  Iterator<NoteEntry> getIter() {
    return notes.iterator;
  }

  @override
  NoteEntry? getCurr() {
    return (curr != -1) ? getEntry(curr).getCurr() : null;
  }

  int getCurrIndex() {
    return curr;
  }

  void setCurr(int newCurr) {
    developer.log("$name: setCurr: from $curr to $newCurr");
    if (getCurr() is NoteCollection) {
      getCurr()!.looseFocus();
    }
    curr = newCurr;
  }

  void switchFocus(NoteEntry noteEntry) {
    setCurr(notes.indexOf(noteEntry));
  }

  @override
  void looseFocus() {
    developer.log("$name: looseFocus: $curr");
    setCurr(-1);
  }

  num getLength() {
    return notes.length;
  }

  void sort(Comparator comparator) {
    notes.sort(comparator);
  }

  void keepSorted(Comparator comparator) {
    this.comparator = comparator;
    sort(comparator);
  }

  void onChange() {
    if (comparator != null) {
      sort(comparator!);
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
