import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/main.dart';
import 'package:groovenation_flutter/ui/chat/chat_page.dart';
import 'package:groovenation_flutter/ui/chat/conversations_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_page.dart';
import 'package:groovenation_flutter/ui/events/event_page.dart';
import 'package:groovenation_flutter/ui/login/login.dart';
import 'package:groovenation_flutter/ui/profile/profile_page.dart';
import 'package:groovenation_flutter/ui/screens/main_home_navigation.dart';
import 'package:groovenation_flutter/ui/search/search_page.dart';
import 'package:groovenation_flutter/ui/settings/notification_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/profile_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/settings_page.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';

class AppBackgroundPage extends StatelessWidget {
  final Widget child;
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
    ));
  }
}
