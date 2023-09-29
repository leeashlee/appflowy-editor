// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return BlocProvider(
            create: (_) => ThemeCubit(settings.getTheme()),
            child: AppView(storage, settings),
          );
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

// ignore: must_be_immutable
class AppView extends StatelessWidget {
  LocalStorage storage;
  SettingsManager settings;
  AppView(this.storage, this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (_, theme) {
        return MaterialApp(
          title: settings["title"] as String? ?? "My text editor",
          theme: theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppFlowyEditorLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          debugShowCheckedModeBanner: false,
          home: HomePage(storage, settings),
        );
      },
    );
  }
}
