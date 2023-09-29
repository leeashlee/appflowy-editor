import 'package:flutter/material.dart';
import 'package:noel_notes/component/themes.dart';

import 'node.dart';
import 'entry.dart';
import 'folder.dart';

class SettingsManager {
  late SettingsFolder settings;

  SettingsManager(Map? json, [bool initStorage = false]) {
    settings =
        (json != null) ? SettingsFolder.fromJson(json) : SettingsFolder();
    if (initStorage) {
      //FIXME: remove this function and put it all in here
      _generateTheme();
    }
  }

  ThemeData getTheme() {
    Brightness b =
        (settings["theme"]["isDark"]) ? Brightness.dark : Brightness.light;
    Accent a = Accent.values[settings["theme"]["accent"]];
    return makeThemeData(b, a);
  }

  Map toJson() {
    return settings.toJson();
  }

  // this defines SettingsManager["example"]
  SettingsNode? operator [](String key) {
    return settings.getValue(key);
  }

  // this is the setter (...["example"] = "example")
  operator []=(String key, dynamic value) {
    settings[key] = value;
  }

  void _generateTheme() {
    if (settings["theme"] == null) {
      settings["theme"] = SettingsFolder({
        "isDark": SettingsEntry<bool>(false),
        "accent": SettingsEntry<int>(Accent.peachPink.index),
      });
    }
  }
}
