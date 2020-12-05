import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/ui/chat/chat_page.dart';
import 'package:groovenation_flutter/ui/chat/conversations_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_settings_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_page.dart';
import 'package:groovenation_flutter/ui/events/event_page.dart';
import 'package:groovenation_flutter/ui/login/login.dart';
import 'package:groovenation_flutter/ui/profile/profile_page.dart';
import 'package:groovenation_flutter/ui/screens/app_background_page.dart';
import 'package:groovenation_flutter/ui/screens/main_home_navigation.dart';
import 'package:groovenation_flutter/ui/search/search_page.dart';
import 'package:groovenation_flutter/ui/settings/change_password_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/notification_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/profile_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/settings_page.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';
import 'package:groovenation_flutter/ui/social/following_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainAppPage extends StatefulWidget {
  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> position;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    position = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: controller, curve: Curves.bounceInOut));

    controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      controller.animateBack(-4.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MaterialApp(
          initialRoute: '/',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return buildPageTransition(MainNavigationScreen(), settings);
              case '/login':
                return buildPageTransition(LoginPageScreen(), settings);
              case '/event':
                return buildPageTransition(EventPageScreen(), settings);
              case '/club':
                return buildPageTransition(ClubPageScreen(), settings);
              case '/conversations':
                return buildPageTransition(ConversationsPageScreen(), settings);
              case '/signup':
                return buildPageTransition(SignUpPageScreen(), settings);
              case '/search':
                return buildPageTransition(SearchPageScreen(), settings);
              case '/settings':
                return buildPageTransition(SettingsPageScreen(), settings);
              case '/notification_settings':
                return buildPageTransition(
                    NotificationSettingsPageScreen(), settings);
              case '/profile_settings':
                return buildPageTransition(
                    ProfileSettingsPageScreen(), settings);
              case '/city_picker':
                return buildPageTransition(CityPickerPageScreen(), settings);
              case '/following':
                return buildPageTransition(FollowingPageScreen(), settings);
              case '/city_picker_settings':
                return buildPageTransition(
                    CityPickerSettingsPageScreen(), settings);
              case '/change_password_settings':
                return buildPageTransition(
                    ChangePasswordSettingsPageScreen(), settings);
              case '/profile_page':
                return buildPageTransition(ProfilePageScreen(), settings);
              default:
                return null;
            }
          },
          // routes: {
          //   '/': (context) => MainNavigationScreen(),
          //   '/login': (context) => LoginPageScreen(),
          //   '/event': (context) => EventPageScreen(),
          //   '/club': (context) => ClubPageScreen(),
          //   '/conversations': (context) => ConversationsPageScreen(),
          //   '/signup': (context) => SignUpPageScreen(),
          //   '/search': (context) => SearchPageScreen(),
          // },
        ),
        Visibility(
          visible: true,
          child: SafeArea(
              child: SlideTransition(
            position: position,
            child: alertItem(context),
          )),
        ),
      ],
    );
  }

  PageTransition buildPageTransition(child, settings) {
    return PageTransition(
      child: child,
      type: PageTransitionType.rightToLeftWithFade,
      settings: settings,
    );
  }

  Widget alertItem(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Card(
          elevation: 7,
          color: Colors.red,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {
                controller.animateBack(-4.0);
              },
              padding: EdgeInsets.zero,
              child: Wrap(children: [
                Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                    padding: EdgeInsets.zero,
                                    child: SizedBox(
                                        height: 64,
                                        width: 64,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Center(
                                              child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 36,
                                          )),
                                        ))),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4, right: 3),
                                                    child: Text(
                                                      "An error occured",
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'LatoBold',
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 3),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 4,
                                                                    right: 1),
                                                            child: Text(
                                                              "Please check your internet connection and try again.",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Lato',
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.5)),
                                                            ))),
                                                  ],
                                                )),
                                          ],
                                        ))),
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 36,
                                )
                              ],
                            )
                          ],
                        )),
                  ],
                )
              ])),
        ));
  }
}

class MainNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: MainNavigationPage());
  }
}

class EventPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: EventPage());
  }
}

class ClubPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club club = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: ClubPage(club));
  }
}

class ConversationsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ConversationsPage());
  }
}

class LoginPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: LoginPage());
  }
}

class SignUpPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: SignUpPage());
  }
}

class SearchPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: SearchPage());
  }
}

class SettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: SettingsPage());
  }
}

class NotificationSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: NotificationSettingsPage());
  }
}

class ProfileSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ProfileSettingsPage());
  }
}

class CityPickerPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: CityPickerPage());
  }
}

class FollowingPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: FollowingPage());
  }
}

class CityPickerSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: CityPickerSettingsPage());
  }
}

class ChangePasswordSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ChangePasswordSettingsPage());
  }
}

class ProfilePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ProfilePage());
  }
}
