// ignore_for_file: avoid_print

import 'node.dart';

class SettingsEntry<T> implements SettingsNode {
  T body;
  SettingsEntry(this.body);

  @override
  Map toJson() {
    return {"type": "SettingsEntry", "body": body};
  }

  static SettingsEntry fromJson(Map json) {
    return SettingsEntry(json["body"]);
  }

  @override
  SettingsEntry<T> operator [](String key) {
    print("Accessing Entry like it is a folder: $key");
    return this;
  }

  @override
  void operator []=(String key, value) {
    body = value;
  }
}
