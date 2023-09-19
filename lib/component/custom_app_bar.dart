import 'package:flutter/material.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          label: Text(widget.label),
          icon: Text(widget.icon),
          suffix: IconButton(
            onPressed: () {
              //TODO fix this bug
              FocusScope.of(context).unfocus();
              String input = widget.controller.text;
              if (input != "") {
                widget.onEnter(input);
              }
              widget.controller.clear();
            },
            icon: const Icon(Unicon.enter),
          ),
        ),
      ),
      actions: const [
        IconButton(onPressed: null, icon: Icon(Unicon.user)),
      ],
    );
    return appBar;
  }
}
