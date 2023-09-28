// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localstorage/localstorage.dart';
import 'package:noel_notes/component/themes.dart';
import 'package:noel_notes/home_page.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: AppView(),
    );
  }
}

// ignore: must_be_immutable
class AppView extends StatelessWidget {
  LocalStorage storage = LocalStorage("storage");

  /// {@macro app_view}
  AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (_, theme) {
        return MaterialApp(
          title: "My text editor",
          theme: theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppFlowyEditorLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          debugShowCheckedModeBanner: false,
          home: FutureBuilder(
            future: storage.ready,
            builder: (context, state) {
              if (state.hasData &&
                  state.connectionState == ConnectionState.done) {
                print("inited storage = ${state.data!}");
                return HomePage(storage);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        );
      },
    );
  }
}


