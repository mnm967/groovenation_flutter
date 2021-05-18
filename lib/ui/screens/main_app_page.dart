import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/ui/chat/conversations_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_settings_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_events_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_moments_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_reviews_page.dart';
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
import 'package:groovenation_flutter/ui/sign_up/create_username.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';
import 'package:groovenation_flutter/ui/social/following_page.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:page_transition/page_transition.dart';

class MainAppPage extends StatefulWidget {
  @override
  MainAppPageState createState() => MainAppPageState();
}

class MainAppPageState extends State<MainAppPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> position;

  String dialogTitle;
  String dialogText;
  Color backgroundColor;
  IconData icon;

  @override
  void initState() {
    super.initState();

    dialogTitle = "An Error Occured";
    dialogText = "Please check your internet connection and try again.";
    backgroundColor = Colors.red;
    icon = Icons.error;

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    position = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: controller, curve: Curves.bounceInOut));

    alertUtil.init(this);

    //alertUtil.sendAlert(dialogTitle, dialogText, backgroundColor, icon);

    // controller.forward();

    // Future.delayed(const Duration(seconds: 5), () {
    //   controller.animateBack(-4.0);
    // });
  }

  openDialog(
    String title,
    String text,
    Color backgroundColor,
    IconData icon,
  ) {
    dialogTitle = title;
    dialogText = text;
    this.backgroundColor = backgroundColor;
    this.icon = icon;

    controller.forward();
    Future.delayed(const Duration(seconds: 5), () {
      closeDialog();
    });
  }

  closeDialog() {
    controller.animateBack(-4.0);
  }

  @override
  Widget build(BuildContext context) {
    print("uid: "+sharedPrefs.userId.toString());

    return Stack(
      children: [
        MaterialApp(  
          title: 'GrooveNation',
          initialRoute: sharedPrefs.userId == null ? '/' : 
            ((sharedPrefs.userCity == null ? '/city_picker' : 
            (sharedPrefs.username == null ? '/create_username' : '/main'))),
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return buildPageTransition(LoginPageScreen(), settings);
              case '/main':
                return buildPageTransition(MainNavigationScreen(), settings);
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
              case '/club_events':
                return buildPageTransition(ClubEventsPageScreen(), settings);
              case '/club_moments':
                return buildPageTransition(ClubMomentsPageScreen(), settings);
              case '/club_reviews':
                return buildPageTransition(ClubReviewsPageScreen(), settings);
              case '/create_username':
                return buildPageTransition(CreateUsernamePageScreen(), settings);
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
          child: MediaQuery( data: MediaQueryData(),
          child: SafeArea(
              child: SlideTransition(
            position: position,
            child: Padding(padding: EdgeInsets.only(top: 16), child: alertItem(context)),
          )),
        )),
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
          color: backgroundColor,
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
                                            icon,
                                            color: backgroundColor,
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
                                                      dialogTitle,
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
                                                              dialogText,
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
    final Event event = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: EventPage(event));
  }
}

class ClubPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club club = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: ClubPage(club));
  }
}

class ClubEventsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club club = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: ClubEventsPage(club));
  }
}

class ClubMomentsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club club = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: ClubMomentsPage(club));
  }
}

class ClubReviewsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club club = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: ClubReviewsPage(club));
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

class CreateUsernamePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: CreateUsernamePage());
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
    final SocialPerson socialPerson = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(child: ProfilePage(socialPerson));
  }
}
