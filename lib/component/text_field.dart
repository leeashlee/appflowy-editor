import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final String label;
  final String hint;
  final Widget icon;

  final controller = TextEditingController();

  CustomTextField(this.title, this.label, this.hint, this.icon, {super.key});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();

  String getText() {
    String input = controller.text;
    if (input == "") {
      input = "Untitled";
    }
    return input;
  }
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _CustomTextFieldState extends State<CustomTextField> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: widget.controller,
      decoration: InputDecoration(
        label: Text(widget.label),
        border: const OutlineInputBorder(),
        hintText: widget.hint,
        icon: widget.icon,
      ),
    );
  }
}
