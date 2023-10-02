// ignore_for_file: file_names, avoid_print

import 'package:appflowy_editor/appflowy_editor.dart';

import 'NoteFolder.dart';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';

abstract class NoteEntry {
  String name;
  NoteEntry(this.name);

  String getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
    _onWrite();
  }

  NoteFile? getCurrNoteFile();

  void looseFocus();

  Map<String, Object?> toJson();

  void _onWrite();

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

class NoteFile extends NoteEntry {
  EditorState body;
  DateTime createdAt = DateTime.now();
  DateTime editedAt = DateTime.now();

  NoteFile(
    String name,
    this.body, [
    DateTime? manualCreatedAt,
    DateTime? manualEditedAt,
  ]) : super(name) {
    createdAt = manualCreatedAt ?? DateTime.now();
    editedAt = manualEditedAt ?? DateTime.now();
  }

  @override
  Map<String, Object> toJson() {
    return {
      "name": name,
      "type": "NoteFile",
      "body": body.document.toJson(),
      "createdAt": createdAt.toUtc().millisecondsSinceEpoch,
      "editedAt": editedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  static NoteFile fromJson(Map input) {
    int createdAt = 0;
    int editedAt = 0;
    if (input.containsKey("createdAt") && input.containsKey("editedAt")) {
      createdAt = input["createdAt"];
      editedAt = input["editedAt"];
    } else {
      dev.log("createdAt or editedAt missing, setting date to 0");
    }

    print("got input: $input");
    return NoteFile(
      input["name"] as String,
      EditorState(
        document: Document.fromJson(
          input["body"]!,
        ),
      ),
      DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
      DateTime.fromMillisecondsSinceEpoch(editedAt, isUtc: true),
    );
  }

  EditorState getBody() {
    return body;
  }

  void setBody(EditorState body) {
    this.body = body;
    _onWrite();
  }

  String getStyledEditedTime() {
    return DateFormat('EEE, dd MMM yyyy, HH:mm').format(editedAt);
  }

  @override
  NoteFile? getCurrNoteFile() {
    return this;
  }

  @override
  void looseFocus() {
    // currently does nothing but might be used to save or smthg
  }

  @override
  void _onWrite() {
    editedAt = DateTime.now();
  }
}
