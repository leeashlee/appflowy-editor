// ignore_for_file: file_names

import 'package:appflowy_editor/appflowy_editor.dart';

abstract class NoteEntry {
  String getName();
  void setName(String name);
  NoteEntry? getCurr();
  void looseFocus();
  Map<String, Object?> toJson();
}

class NoteFile implements NoteEntry {
  String name;
  EditorState body;

  NoteFile(this.name, this.body);

  @override
  Map<String, Object> toJson() {
    return {"title": name, "body": body.document.toJson()};
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
  NoteEntry? getCurr() {
    return this;
  }

  @override
  void looseFocus() {
    // currently does nothing but might be used to save or smthg
  }
}
