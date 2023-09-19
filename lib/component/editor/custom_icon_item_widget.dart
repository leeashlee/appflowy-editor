import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class CustomSVGIconItemWidget extends StatelessWidget {
  const CustomSVGIconItemWidget({
    super.key,
    this.size = const Size.square(30.0),
    this.iconSize = const Size.square(18.0),
    this.iconName,
    this.iconBuilder,
    required this.isHighlight,
    required this.highlightColor,
    required this.normalColor,
    this.tooltip,
    this.onPressed,
  });

  final Size size;
  final Size iconSize;
  final String? iconName;
  final WidgetBuilder? iconBuilder;
  final bool isHighlight;
  final Color highlightColor;
  final Color normalColor;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    Widget child = iconBuilder != null
        ? iconBuilder!(context)
        : EditorSvg(
            name: iconName,
            color: isHighlight ? highlightColor : normalColor,
            width: iconSize.width,
            height: iconSize.height,
          );
    if (onPressed != null) {
      child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          padding: EdgeInsets.zero,
          icon: child,
          iconSize: size.width,
          onPressed: onPressed,
        ),
      );
    }
    if (tooltip != null) {
      child = Tooltip(
        textAlign: TextAlign.center,
        preferBelow: false,
        message: tooltip,
        waitDuration: const Duration(milliseconds: 500),
        child: child,
      );
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}
