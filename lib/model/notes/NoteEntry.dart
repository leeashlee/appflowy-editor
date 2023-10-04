import 'package:flutter/foundation.dart';
import 'package:noel_notes/model/notes/note_file.dart';
import 'NoteFolder.dart';

abstract class NoteEntry extends ChangeNotifier {
  String name;
  NoteEntry(this.name);

  String getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  NoteFile? getCurrNoteFile();

  void looseFocus();

  Map<String, Object?> toJson();

  static NoteEntry fromJson(Map<String, Object?> input, bool withFocus) {
    print("NoteEntry fromJson $input");
    switch (input["type"]) {
      case "NoteCollection":
        return NoteFolder.fromJson(input, withFocus);
      case "NoteFile":
        return NoteFile.fromJson(input);
      default:
        throw UnimplementedError("NoteEntry: Unknown type: ${input['type']}");
    }
  }
}
