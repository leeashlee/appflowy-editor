// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

enum Accents {
  peachPink(Color.fromARGB(255, 255, 164, 194), "Peach Pink"),
  babyBlue(Color.fromARGB(255, 157, 220, 251), "Baby Blue"),
  navy(Color.fromARGB(255, 125, 136, 217), "Navy");

  const Accents(this.color, this.title);

  final Color color;
  final String title;
}

class ThemeCubit extends Cubit<ThemeData> {
  /// {@macro brightness_cubit}
  ThemeCubit() : super(_lightTheme);

  static ThemeData _makeThemeData(Brightness brightness, Color color) {
    return ThemeData(
      fontFamily: GoogleFonts.quicksand().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }

  static final _lightTheme = _makeThemeData(Brightness.light, Accents.peachPink.color);

  static final _darkTheme = _makeThemeData(Brightness.dark, Accents.peachPink.color);

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
  }
}
