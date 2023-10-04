// ignore_for_file: avoid_print, must_be_immutable

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:noel_notes/appwrite/auth_api.dart';
import 'package:noel_notes/pages/login.dart';
import 'package:provider/provider.dart';

import 'component/themes.dart';
import 'home_page.dart';
import 'model/settings/manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthAPI(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  LocalStorage storage = LocalStorage("storage");
  // FIXME: replace with ChangeNotifierProvider
  // https://docs.flutter.dev/data-and-backend/state-mgmt/simple
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
    final value = context.watch<AuthAPI>().status;
    return MaterialApp(
      title: "Note Editor",
      theme: makeThemeData(widget.settings),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      debugShowCheckedModeBanner: false,
      home: value == AuthStatus.uninitialized
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : value == AuthStatus.authenticated
              ? HomePage(widget.storage, widget.settings)
              : const LoginPage(),
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
