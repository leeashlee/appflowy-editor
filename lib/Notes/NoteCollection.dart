// ignore_for_file: file_names

import 'package:noel_notes/Notes/NoteEntry.dart';
import 'dart:developer' as developer;

class NoteCollection implements NoteEntry {
  String name;
  List<NoteEntry> notes = [];
  NoteEntry? curr;
  Comparator? comparator;

  NoteCollection(
    this.name, [
    bool withFocus = false,
    List<NoteEntry> initial = const [],
    int manualIndex = -1,
  ]) {
    if (initial.length != 0) {
      developer
          .log("starting NoteCollection with $initial and focus = $withFocus");
    }
    notes.addAll(initial);
    // set the current notefile (if were told this collection is in focus)
    if (withFocus) {
      // prefer the manual index
      if (manualIndex > -1) {
        curr = notes[manualIndex];
        // DISCOURAGED: searching for the first notefile and just taking that
      } else {
        curr = notes.firstWhere((element) => element is NoteFile);
      }
      // throw an exception rather sooner than waiting for undefined behaviour
      if (curr == null) {
        throw Exception("no element in focus but this collection is in focus");
      }
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
      //FIXME Fixing the logic here so you could remove the entry you're currently on.
    } else if (i == _getCurrIndex()) {
      throw Exception("cant remove the Entry that your currently editing");
    }
    notes.remove(old);
    _onWrite();
  }

  @override
  NoteEntry? getCurrNotefile() {
    return (curr != null) ? curr!.getCurrNotefile() : null; // be recursive
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
    if (curr != null && curr is NoteCollection) {
      curr!.looseFocus();
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

  static NoteEntry fromJson(Map input, bool withFocus) {
    List<NoteEntry> body = [];
    int curr = -1;
    if (input.containsKey("curr")) {
      curr = input["curr"];
    }
    for (var inp in input["body"]!) {
      body.add(NoteEntry.fromJson(inp, false));
    }
    return NoteCollection(
      input["name"] as String,
      (withFocus || curr > -1),
      body,
      curr,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      "name": name,
      "curr": _getCurrIndex(),
      "type": "NoteCollection",
      "body": notes.map((x) {
        return x.toJson();
      }).toList(),
    };
  }
}
