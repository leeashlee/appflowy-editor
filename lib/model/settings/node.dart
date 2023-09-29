import 'entry.dart';
import 'folder.dart';

abstract class SettingsNode {
  static SettingsNode fromJson(Map json) {
    print("parsing: $json");
    switch (json["type"]) {
      case "SettingsFolder":
        return SettingsFolder.fromJson(json);
      case "SettingsEntry":
        return SettingsEntry.fromJson(json);
      default:
        throw UnimplementedError("Unknown type: ${json['type']}");
    }
  }

  // this defines ...["example"]
  dynamic operator [](String key);
  // this is the setter (...["example"] = "example")
  operator []=(String key, dynamic value);
  Map toJson();
}
