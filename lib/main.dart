// ignore_for_file: avoid_print, must_be_immutable

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'component/themes.dart';
import 'home_page.dart';
import 'model/settings/manager.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  LocalStorage storage = LocalStorage("storage");
  late SettingsManager settings;

  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.ready,
      builder: (context, state) {
        if (state.hasData && state.connectionState == ConnectionState.done) {
          print("inited storage = ${state.data!}");
          // init settings
          settings = SettingsManager(storage.getItem("settings"));
          return AppView(storage, settings);
        } else {
          // TODO: proper loading screen
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class AppView extends StatefulWidget {
  LocalStorage storage;
  SettingsManager settings;
  AppView(this.storage, this.settings, {Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  void initState() {
    // subcribe to theme & accent
    for (final e in [Settings.theme, Settings.accent]) {
      widget.settings.addObserver(e, SettingEvent.write, (field, event) {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "settings.getValue<String>(Settings.editorTitle)",
      theme: makeThemeData(widget.settings),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      debugShowCheckedModeBanner: false,
      home: HomePage(widget.storage, widget.settings),
    );
  }
}

ThemeData makeThemeData(SettingsManager mgr) {
  return ThemeData(
    fontFamily: GoogleFonts.quicksand().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mgr.getValue<Accent>(Settings.accent).color,
      brightness: mgr.getValue<Brightness>(Settings.theme),
    ),
    useMaterial3: true,
  );
}
