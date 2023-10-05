// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:noel_notes/model/settings/manager.dart';

enum Accent {
  peachPink(Color.fromARGB(255, 255, 164, 194), "Peach Pink"),
  babyBlue(Color.fromARGB(255, 157, 220, 251), "Baby Blue"),
  navy(Color.fromARGB(255, 125, 136, 217), "Navy"),
  peachYellow(Color.fromARGB(255, 247, 219, 167), "Peach Yellow"),
  brownSugar(Color.fromARGB(255, 197, 123, 87), "Brown Sugar"),
  darkMagenta(Color.fromARGB(255, 161, 22, 146), "Dark Magenta"),
  brightPink(Color.fromARGB(255, 255, 79, 121), "Bright Pink"),
  melon(Color.fromARGB(255, 255, 180, 154), "Melon"),
  vermilion(Color.fromARGB(255, 221, 64, 58), "Vermilion"),
  avocado(Color.fromARGB(255, 105, 122, 33), "Avocado"),
  oldGold(Color.fromARGB(255, 184, 180, 45), "Old Gold");

  const Accent(this.color, this.title);

  final Color color;
  final String title;
}

class ThemeManager {
  SettingsManager settings;
  ThemeManager(this.settings);
  Brightness get brightness => settings.getValue<Brightness>(Settings.theme);
}

class ThemeCubit {
  SettingsManager settings;
  ThemeCubit(this.settings);
}
