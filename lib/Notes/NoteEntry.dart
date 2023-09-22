// ignore_for_file: file_names

import 'package:appflowy_editor/appflowy_editor.dart';

import 'NoteCollection.dart';

abstract class NoteEntry {
  String getName();
  void setName(String name);
  NoteEntry? getCurrNotefile();
  void looseFocus();
  Map<String, Object?> toJson();
  static NoteEntry fromJson(Map<String, Object?> input, bool withFocus) {
    print("NoteEntry fromJson $input");
    switch (input["type"]) {
      case "NoteCollection":
        return NoteCollection.fromJson(input, withFocus);
      case "NoteFile":
        return NoteFile.fromJson(input);
      default:
        throw UnimplementedError("NoteEntry: Unknown type: ${input['type']}");
    }
  }
}

class NoteFile implements NoteEntry {
  String name;
  EditorState body;

  NoteFile(this.name, this.body);

  @override
  Map<String, Object> toJson() {
    return {"name": name, "type": "NoteFile", "body": body.document.toJson()};
  }

  static NoteFile fromJson(Map input) {
    print("got input: $input");
    return NoteFile(
      input["name"] as String,
      EditorState(
        document: Document.fromJson(
          input["body"]!,
        ),
      ),
    );
  }

  @override
  String getName() {
    return name;
  }

  @override
  void setName(String name) {
    this.name = name;
  }

  EditorState getBody() {
    return body;
  }

  void setBody(EditorState body) {
    this.body = body;
  }

  @override
  NoteEntry? getCurrNotefile() {
    return this;
  }

  @override
  void looseFocus() {
    // currently does nothing but might be used to save or smthg
  }
}
