import 'dart:js';

import 'package:flutter/material.dart';
import 'package:noel_notes/component/alert_dialog.dart';
import 'package:noel_notes/model/settings/manager.dart';

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
          children: buildButtons(context, settings),
        ),
      ),
    );
  }

  List<MenuItemButton> buildButtons(
    BuildContext context,
    SettingsManager settings,
  ) {
    List<MenuItemButton> out = [];
    for (final e in Settings.values) {
      out.add(
        customBtn(
          e.icon,
          e.name,
          context,
          e.allowedType,
          e.allowedList,
          settings.getValue(e),
          e.value,
          (value) {
            settings.setValue(e, value);
          },
        ),
      );
    }
    return out;
  }

  MenuItemButton customBtn(
    IconData icon,
    String name,
    BuildContext context,
    Type allowedType,
    List? allowedList,
    currVal,
    defVal,
    void Function(dynamic value) onChange,
  ) {
    return MenuItemButton(
      leadingIcon: Icon(icon),
      child: Text(name),
      onPressed: () => showDialog<String>(
        context: context,
        builder: (context) => genChild(
          allowedList,
          allowedType,
          context,
          currVal,
          defVal,
          onChange,
          name,
        ),
      ),
    );
  }

  Widget genChild(
    List? allowedList,
    Type allowedType,
    BuildContext context,
    currVal,
    defVal,
    void Function(dynamic value) onChange,
    String name,
  ) {
    if (defVal is Enum) {
      // ugh you cant compare types with each other >:(
      return genRadio(allowedList!, context, currVal, onChange, name);
    } else if (allowedType == String) {
      if (allowedList != null) {
        return genRadio(allowedList, context, currVal, onChange, name);
      } else {
        //FIXME: URGENT should be properly implemented
        return CustomAlertDialog(AlertType.renameFile, (input) {
          print(input);
          throw UnimplementedError();
        });
      }
    } else {
      throw UnimplementedError(
        "Preference redering not implemented yet for: $allowedType",
      );
    }
  }

  SimpleDialog genRadio(
    List allowedList,
    BuildContext context,
    dynamic currVal,
    void Function(dynamic value) onChange,
    String name,
  ) {
    List<RadioListTile> out = [];
    for (final e in allowedList) {
      print("$e, ${e.runtimeType}");
      out.add(RadioListTile(
        value: e,
        title: Text(e.toString()),
        groupValue: currVal,
        onChanged: (value) {
          onChange(value);
          Navigator.pop(context);
        },
      ));
    }
    return SimpleDialog(
      title: Text("Change $name?"),
      children: out,
    );
  }
}
