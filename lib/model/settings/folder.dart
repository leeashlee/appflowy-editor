import 'entry.dart';
import 'node.dart';

class SettingsFolder implements SettingsNode {
  Map<String, SettingsNode> body = {};

  SettingsFolder([
    Map<String, SettingsNode> initialBody = const {},
  ]) {
    body.addAll(initialBody);
  }

  static SettingsFolder fromJson(Map json) {
    print("Parsing: $json");
    // parse every entry from json
    Map<String, SettingsNode> out = {};
    for (final e in (json["body"] as Map).entries) {
      out[e.key] = SettingsNode.fromJson(e.value);
    }
    return SettingsFolder(out);
  }

  @override
  Map toJson() {
    return {
      "type": "SettingsFolder",
      "body": body.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  SettingsNode? getValue(String key) {
    return body.containsKey(key) ? body[key] : null;
  }

  // this defines SettingsFolder["example"]
  operator [](String key) {
    var val = getValue(key);
    return (val is SettingsEntry) ? val.body : val;
  }

  @override
  operator []=(String key, dynamic value) {
    if (body[key] is SettingsEntry) {
      (body[key] as SettingsEntry).body = value;
    } else if (body[key] is SettingsFolder) {
      body[key] = value;
    }
  }
}
