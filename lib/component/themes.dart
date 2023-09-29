// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noel_notes/model/settings/manager.dart';

/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

enum Accent {
  peachPink(Color.fromARGB(255, 255, 164, 194), "Peach Pink"),
  babyBlue(Color.fromARGB(255, 157, 220, 251), "Baby Blue"),
  navy(Color.fromARGB(255, 125, 136, 217), "Navy");

  const Accent(this.color, this.title);

  final Color color;
  final String title;
}

class ThemeManager {
  SettingsManager settings;
  ThemeManager(this.settings);
  Brightness get brightness => settings.getValue<Brightness>(Settings.theme);
}

class ThemeCubit extends Cubit<ThemeManager> {
  SettingsManager settings;
  ThemeCubit(super.initialState, this.settings);
}
