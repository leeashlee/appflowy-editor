import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noel_notes/component/themes.dart';
import 'package:noel_notes/model/settings/entry.dart';
import 'package:noel_notes/model/settings/folder.dart';
import 'package:noel_notes/model/settings/manager.dart';

import '../component/icons/unicon_icons.dart';

class SettingsScreen extends StatelessWidget {
  SettingsManager settings;
  SettingsScreen(this.settings, {super.key});
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
              child: const Text('Theme'),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text("Change theme mode?"),
                  children: List<RadioListTile>.generate(
                      Brightness.values.length,
                      (index) => RadioListTile(
                            title: Text(Brightness.values[index].name),
                            value: index == 0, // 0 is dark
                            groupValue: settings["theme"]!["isDark"],
                            onChanged: (value) {
                              settings["theme"]!["isDark"] = value;
                              context.read<ThemeCubit>().toggleTheme();
                              Navigator.pop(context);
                            },
                          )),
                ),
              ),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Unicon.palette),
              child: const Text('Accents'),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text("Change theme color?"),
                  children: List<RadioListTile>.generate(
                    Accent.values.length,
                    (index) => RadioListTile(
                      value: index,
                      title: Text(Accent.values[index].title),
                      groupValue: Accent.values[settings["theme"]!["accent"]],
                      onChanged: (value) {
                        // the accent gets saved as the index
                        settings["theme"]!["accent"] = value;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
