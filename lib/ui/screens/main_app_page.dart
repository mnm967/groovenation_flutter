import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/ui/chat/chat_page.dart';
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
import 'package:groovenation_flutter/ui/search/club_search.dart';
import 'package:groovenation_flutter/ui/search/search_page.dart';
import 'package:groovenation_flutter/ui/search/social_people_search.dart';
import 'package:groovenation_flutter/ui/settings/change_password_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/notification_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/profile_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/settings_page.dart';
import 'package:groovenation_flutter/ui/sign_up/create_username.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';
import 'package:groovenation_flutter/ui/social/create_post_page.dart';
import 'package:groovenation_flutter/ui/social/following_page.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/create_post_arguments.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';

class MainAppPage extends StatefulWidget {
  @override
  MainAppPageState createState() => MainAppPageState();
}

class MainAppPageState extends State<MainAppPage>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> position;

  AnimationController welcomeController;
  Animation<Offset> welcomePosition;

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

    welcomeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    welcomePosition = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: welcomeController, curve: Curves.bounceInOut));

    alertUtil.init(this);

    if (sharedPrefs.userId != null) {
      // welcomeController.forward();
    }

    // Future.delayed(const Duration(seconds: 10), () {
    //   welcomeController.animateBack(-4.0);
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
    print("uid: " + sharedPrefs.userId.toString());

    return Stack(
      children: [
        MaterialApp(
          title: 'GrooveNation',
          initialRoute: sharedPrefs.userId == null
              ? '/log'
              : ((sharedPrefs.userCity == null
                  ? '/city_picker'
                  : (sharedPrefs.username == null
                      ? '/create_username'
                      : '/main'))),
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/log':
                return buildPageTransition(LoginPageScreen(), settings);
              case '/main':
                return buildPageTransition(MainNavigationScreen(), settings);
              case '/event':
                return buildPageTransition(EventPageScreen(), settings);
              case '/club':
                return buildPageTransition(ClubPageScreen(), settings);
              case '/conversations':
                return buildPageTransition(ConversationsPageScreen(), settings);
              case '/chat':
                return buildPageTransition(ChatPageScreen(), settings);
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
              case '/create_post':
                return buildPageTransition(CreatePostPageScreen(), settings);
              case '/club_search':
                return buildPageTransition(ClubSearchPageScreen(), settings);
              case '/social_people_search':
                return buildPageTransition(
                    SocialPeopleSearchPageScreen(), settings);
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
                return buildPageTransition(
                    CreateUsernamePageScreen(), settings);
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
            child: MediaQuery(
              data: MediaQueryData(),
              child: SafeArea(
                  child: SlideTransition(
                position: position,
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: alertItem(context)),
              )),
            )),
        Visibility(
            visible: true,
            child: MediaQuery(
              data: MediaQueryData(),
              child: SafeArea(
                  child: SlideTransition(
                position: welcomePosition,
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: welcomeItem(context)),
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

  Widget welcomeItem(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 24, left: 10, right: 10, bottom: 10),
        child: Card(
          elevation: 7,
          color: Colors.purple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: AssetImage("assets/images/main_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: FlatButton(
                  onPressed: () {
                    welcomeController.animateBack(-4.0);
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
                                                backgroundColor: Colors.purple,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        "${sharedPrefs.profilePicUrl}")))),
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 4,
                                                                right: 3),
                                                        child: Text(
                                                          "Welcome Back, ${sharedPrefs.username}",
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'LatoBold',
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ))),
                                    Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                    child: Container(
                                      height: 192,
                                      width: double.infinity,
                                      child: Image.asset(
                                        "assets/images/welcome_image.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                                // GridView.count(
                                //                     physics:
                                //                         NeverScrollableScrollPhysics(),
                                //                     shrinkWrap: true,
                                //                     childAspectRatio: 3,
                                //                     padding: EdgeInsets.only(
                                //                         right: 16,
                                //                         left: 16,
                                //                         top: 24),
                                //                     crossAxisCount: 2,
                                //                     children: [
                                //                       Padding(
                                //                         padding: EdgeInsets.only(
                                //                             left: 12, right: 8),
                                //                         child: Container(
                                //                             width: double.infinity,
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               border: Border.all(
                                //                                   width: 1.0,
                                //                                   color:
                                //                                       Colors.white),
                                //                               borderRadius:
                                //                                   BorderRadius.all(
                                //                                       Radius
                                //                                           .circular(
                                //                                               10.0)),
                                //                             ),
                                //                             child: FlatButton(
                                //                               padding:
                                //                                   EdgeInsets.zero,
                                //                               onPressed: () {

                                //                               },
                                //                               child: Text(
                                //                                 "OPEN SOCIAL",
                                //                                 style: TextStyle(
                                //                                     fontFamily:
                                //                                         'LatoBold',
                                //                                     color: Colors
                                //                                         .white),
                                //                               ),
                                //                             )),
                                //                       ),
                                //                       Padding(
                                //                         padding: EdgeInsets.only(
                                //                             right: 12, left: 8),
                                //                         child: Container(
                                //                             width: double.infinity,
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               border: Border.all(
                                //                                   width: 1.0,
                                //                                   color:
                                //                                       Colors.white),
                                //                               borderRadius:
                                //                                   BorderRadius.all(
                                //                                       Radius
                                //                                           .circular(
                                //                                               10.0)),
                                //                             ),
                                //                             child: FlatButton(
                                //                               padding:
                                //                                   EdgeInsets.zero,
                                //                               onPressed: () {

                                //                               },
                                //                               child: Text(
                                //                                 "VIEW CLUBS",
                                //                                 style: TextStyle(
                                //                                     fontFamily:
                                //                                         'LatoBold',
                                //                                     color: Colors
                                //                                             .white),
                                //                               ),
                                //                             )),
                                //                       )
                                //                     ]),
                              ],
                            )),
                      ],
                    )
                  ]))),
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

class ChatPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatPageArguments args = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(
        child: ChatPage(args.conversation, args.messageToSend));
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

class CreatePostPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CreatePostArguments args = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(
        child: CreatePostPage(args.mediaPath, args.isVideo));
  }
}

class ClubSearchPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Function onClubSelected = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(
        child: ClubSearchPage(
      onClubSelected: onClubSelected,
    ));
  }
}

class SocialPeopleSearchPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Function onUserSelected = ModalRoute.of(context).settings.arguments;
    return AppBackgroundPage(
        child: SocialPeopleSearchPage(
      onUserSelected: onUserSelected,
    ));
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
