import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/ui/screens/page_screens.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/navigation_service.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:page_transition/page_transition.dart';

class MainAppPage extends StatefulWidget {
  @override
  MainAppPageState createState() => MainAppPageState();
}

class MainAppPageState extends State<MainAppPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;

  String? _dialogTitle;
  String? _dialogText;
  Color? _backgroundColor;
  IconData? _icon;

  void _checkNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Allow Notifications'),
            content: Text('Our app would like to send you notifications'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Don\'t Allow',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () => AwesomeNotifications()
                    .requestPermissionToSendNotifications()
                    .then((_) => Navigator.pop(context)),
                child: Text(
                  'Allow',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _checkNotificationPermission();

    _dialogTitle = "An Error Occured";
    _dialogText = "Please check your internet connection and try again.";
    _backgroundColor = Colors.red;
    _icon = Icons.error;

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _position = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));

    alertUtil.init(this);
  }

  openDialog(
    String title,
    String text,
    Color backgroundColor,
    IconData icon,
  ) {
    try {
      setState(() {
        _dialogTitle = title;
        _dialogText = text;
        this._backgroundColor = backgroundColor;
        this._icon = icon;
      });

      _controller.forward();
      Future.delayed(const Duration(seconds: 5), () {
        closeDialog();
      });
    } catch (e) {
      print(e);
    }
  }

  closeDialog() {
    _controller.animateBack(-4.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MaterialApp(
          title: 'GrooveNation',
          navigatorKey: NavigationService.navigatorKey,
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
                return _buildPageTransition(LoginPageScreen(), settings);
              case '/main':
                return _buildPageTransition(MainNavigationScreen(), settings);
              case '/event':
                return _buildPageTransition(EventPageScreen(), settings);
              case '/club':
                return _buildPageTransition(ClubPageScreen(), settings);
              case '/conversations':
                return _buildPageTransition(
                    ConversationsPageScreen(), settings);
              case '/chat':
                return _buildPageTransition(ChatPageScreen(), settings);
              case '/signup':
                return _buildPageTransition(SignUpPageScreen(), settings);
              case '/search':
                return _buildPageTransition(SearchPageScreen(), settings);
              case '/settings':
                return _buildPageTransition(SettingsPageScreen(), settings);
              case '/notification_settings':
                return _buildPageTransition(
                    NotificationSettingsPageScreen(), settings);
              case '/profile_settings':
                return _buildPageTransition(
                    ProfileSettingsPageScreen(), settings);
              case '/city_picker':
                return _buildPageTransition(CityPickerPageScreen(), settings);
              case '/following':
                return _buildPageTransition(FollowingPageScreen(), settings);
              case '/create_post':
                return _buildPageTransition(CreatePostPageScreen(), settings);
              case '/club_search':
                return _buildPageTransition(ClubSearchPageScreen(), settings);
              case '/social_people_search':
                return _buildPageTransition(
                    SocialPeopleSearchPageScreen(), settings);
              case '/city_picker_settings':
                return _buildPageTransition(
                    CityPickerSettingsPageScreen(), settings);
              case '/change_password_settings':
                return _buildPageTransition(
                    ChangePasswordSettingsPageScreen(), settings);
              case '/profile_page':
                return _buildPageTransition(ProfilePageScreen(), settings);
              case '/club_events':
                return _buildPageTransition(ClubEventsPageScreen(), settings);
              case '/club_moments':
                return _buildPageTransition(ClubMomentsPageScreen(), settings);
              case '/club_reviews':
                return _buildPageTransition(ClubReviewsPageScreen(), settings);
              case '/create_username':
                return _buildPageTransition(
                    CreateUsernamePageScreen(), settings);
              default:
                return null;
            }
          },
        ),
        Visibility(
          visible: true,
          child: MediaQuery(
            data: MediaQueryData(),
            child: SafeArea(
              child: SlideTransition(
                position: _position,
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: _alertItem(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  PageTransition _buildPageTransition(child, settings) {
    return PageTransition(
      child: child,
      type: PageTransitionType.rightToLeftWithFade,
      settings: settings,
    );
  }

  Widget _alertItemIcon() {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 48,
        width: 48,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Center(
            child: Icon(
              _icon,
              color: _backgroundColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _alertItemText(String? text, bool isTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 4, right: 1),
            child: Text(
              text!,
              textAlign: TextAlign.start,
              maxLines: isTitle ? 1 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: isTitle ? 18 : 16,
                color: isTitle ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _alertItemContent() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _alertItemText(_dialogTitle, true),
            Padding(
              padding: EdgeInsets.only(top: 3),
            ),
            _alertItemText(_dialogText, false),
          ],
        ),
      ),
    );
  }

  Widget _alertItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 7,
        color: _backgroundColor,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: FlatButton(
          onPressed: () {
            _controller.animateBack(-4.0);
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
                          _alertItemIcon(),
                          _alertItemContent(),
                          Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
