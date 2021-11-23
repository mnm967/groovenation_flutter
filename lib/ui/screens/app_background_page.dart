import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBackgroundPage extends StatelessWidget {
  final Widget? child;
  AppBackgroundPage({this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/main_background.png"),
                    fit: BoxFit.cover),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.0),
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.25),
            ),
            Container(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
