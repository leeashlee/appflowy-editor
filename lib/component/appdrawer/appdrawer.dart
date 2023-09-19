import 'package:flutter/material.dart';

class CustomAppDrawer extends Drawer {
  final String label;
  final String icon;
  final Function(String input) onEnter;

  CustomAppDrawer(this.label, this.icon, this.onEnter, {super.key});

  State<CustomAppDrawer> createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
