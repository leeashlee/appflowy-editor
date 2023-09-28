// ignore_for_file: avoid_print

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

class ThemeCubit extends Cubit<ThemeData> {
  static Color peachPink = const Color.fromARGB(255, 255, 164, 194);
  static Color babyBlue = const Color.fromARGB(255, 157, 220, 251);
  static Color navy = const Color.fromARGB(255, 125, 136, 217);

  /// {@macro brightness_cubit}
  ThemeCubit() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    fontFamily: GoogleFonts.quicksand().fontFamily,
    /*colorScheme: ColorScheme.fromSeed(
      seedColor: peachPink,
    ),*/
    brightness: Brightness.light,
    useMaterial3: true,
  );

  static final _darkTheme = ThemeData(
    fontFamily: GoogleFonts.quicksand().fontFamily,
    /*colorScheme: ColorScheme.fromSeed(
      seedColor: peachPink,
    ),*/
    brightness: Brightness.dark,
    useMaterial3: true,
  );

  static final peachPinkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: peachPink,
    ),
  );

  static final babyBlueTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: babyBlue,
    ),
  );

  static final navyTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
    ),
  );

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
  }
}
