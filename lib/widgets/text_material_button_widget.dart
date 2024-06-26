import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextMaterialButton extends StatelessWidget {
  final Widget? child;
  final Function? onTap;
  TextMaterialButton({this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap as void Function()?,
        splashColor: Colors.white.withOpacity(0.3),
        child: Container(
          child: child,
        ),
      ),
    );
  }
}
