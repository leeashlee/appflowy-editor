import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unicon_icons.dart';

enum UserMenu {
  accountinfo,
  settings,
  about,
}

class CustomAppBar extends AppBar {
  final String label;
  final String icon;
  final Function(String input) onEnter;

  final controller = TextEditingController();

  CustomAppBar(this.label, this.icon, this.onEnter, {super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          label: Text(widget.label),
          icon: Text(widget.icon),
          suffix: IconButton(
            onPressed: () {
              setState(() {
                FocusScope.of(context).unfocus();
                String input = widget.controller.text;
                if (input != "") {
                  widget.onEnter(input);
                }
                widget.controller.clear();
              });
            },
            icon: const Icon(Unicon.enter),
          ),
        ),
      ),
      actions: [
        MenuAnchor(
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Unicon.user),
              tooltip: 'Settings',
            );
          },
          menuChildren: [
            const PopupMenuItem<UserMenu>(
              enabled: false,
              value: UserMenu.accountinfo,
              child: Row(
                children: [
                  Icon(Unicon.chat_bubble_user),
                  SizedBox(width: 10),
                  Text("Account Info"),
                ],
              ),
            ),
            PopupMenuDivider(),
            const PopupMenuItem<UserMenu>(
              enabled: false,
              value: UserMenu.settings,
              child: Row(
                children: [
                  Icon(Unicon.wrench),
                  SizedBox(width: 10),
                  Text("Settings"),
                ],
              ),
            ),
            PopupMenuDivider(),
            const PopupMenuItem<UserMenu>(
              enabled: false,
              value: UserMenu.about,
              child: Row(
                children: [
                  Icon(Unicon.info_circle),
                  SizedBox(width: 10),
                  Text("About"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
    return appBar;
  }
}
