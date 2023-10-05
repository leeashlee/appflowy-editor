import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noel_notes/model/settings/manager.dart';
import 'package:noel_notes/pages/about.dart';
import 'package:noel_notes/pages/account_info.dart';
import 'package:noel_notes/pages/settings.dart';
import 'package:noel_notes/appwrite/auth_api.dart';
import 'package:provider/provider.dart';

import 'icons/unicon_icons.dart';

// ignore: must_be_immutable
class CustomAppBar extends AppBar {
  final String label;
  final String icon;
  final Function(String input) onEnter;
  SettingsManager settings;
  final controller = TextEditingController();

  CustomAppBar(this.label, this.icon, this.onEnter, this.settings, {super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  void signOut() {
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountPage()),
              ),
              leadingIcon: const Icon(Unicon.chat_bubble_user),
              child: const Text("Account Info"),
            ),
            const PopupMenuDivider(),
            MenuItemButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(widget.settings),
                ),
              ),
              leadingIcon: const Icon(Unicon.wrench),
              child: const Text("Settings"),
            ),
            const PopupMenuDivider(),
            MenuItemButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              ),
              leadingIcon: const Icon(Unicon.info_circle),
              child: const Text("About"),
            ),
            const PopupMenuDivider(),
            MenuItemButton(
              style: MenuItemButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                //backgroundColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                context.read<AuthAPI>().signOut();
              },
              leadingIcon: const Icon(Icons.logout),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ],
    );
  }
}
