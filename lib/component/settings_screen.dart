import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noel_notes/main.dart';
import 'package:noel_notes/unicon_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            MenuItemButton(
              leadingIcon: const Icon(Unicon.brightness_half),
              child: const Text('Change Theme'),
              //TODO Changing the theme in a radio menu
              onPressed: () => {
                context.read<ThemeCubit>().toggleTheme(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
