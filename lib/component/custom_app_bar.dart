import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unicon_icons.dart';

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
            MenuItemButton(
              child: Text("Account Info"),
              leadingIcon: Icon(Unicon.chat_bubble_user),
            ),
            PopupMenuDivider(),
            MenuItemButton(
              child: Text("Settings"),
              leadingIcon: Icon(Unicon.wrench),
            ),
            PopupMenuDivider(),
            MenuItemButton(
              child: Text("About"),
              leadingIcon: Icon(Unicon.info_circle),
            ),
          ],
        ),
      ],
    );
    return appBar;
  }
}
