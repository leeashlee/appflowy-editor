// ignore_for_file: file_names

import 'package:appflowy_editor/appflowy_editor.dart';

abstract class NoteEntry {
  String getName();
  NoteEntry? getCurr();
  void looseFocus();
  Map<String, Object> toJson();
}

class NoteFile implements NoteEntry {
  String title;
  EditorState body;

  NoteFile(this.title, this.body);

  @override
  Map<String, Object> toJson() {
    return {"title": title, "body": body.document.toJson()};
  }

  @override
  String getName() {
    return title;
  }

  String getTitle() {
    return title;
  }

  void setTitle(String title) {
    this.title = title;
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