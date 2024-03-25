import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url, forceWebView: true)
      : alertUtil.sendAlert(
          BASIC_ERROR_TITLE, CANNOT_LAUNCH_URL_PROMPT, Colors.red, Icons.error);

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(),
                  _mainContainer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainContainer() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 24, bottom: 8),
      children: [
        _settingsItem(
          context,
          "Profile",
          "Edit your Profile settings",
          Icons.person,
          () {
            Navigator.pushNamed(context, '/profile_settings');
          },
        ),
        _settingsItem(
          context,
          "Following",
          "View people you are following",
          Icons.people_outline,
          () {
            Navigator.pushNamed(context, '/following');
          },
        ),
        _settingsItem(
          context,
          "Change City",
          "Look for clubs and events in a different city",
          Icons.location_city,
          () {
            Navigator.pushNamed(context, '/city_picker_settings');
          },
        ),
        _settingsItem(
          context,
          "Notifications",
          "Change your Notification settings",
          Icons.notifications,
          () {
            Navigator.pushNamed(context, '/notification_settings');
          },
        ),
        _settingsItem(
          context,
          "Contact Us",
          "Have a question or an issue? Feel free to contact us",
          Icons.chat,
          () => _launchURL(GROOVENATION_WEBSITE_LINK),
        ),
        _settingsItem(
          context,
          "About",
          "Learn more about GrooveNation",
          Icons.local_bar,
          () => _launchURL(GROOVENATION_WEBSITE_LINK),
        ),
        _settingsItem(
          context,
          "Terms and Conditions",
          "Read our Terms and Conditions",
          Icons.description,
          () => _launchURL(TERMS_AND_CONDITIONS_LINK),
        ),
        _settingsItem(
          context,
          "Privacy Policy",
          "Read our Privacy Policy",
          Icons.verified_user,
          () => _launchURL(PRIVACY_POLICY_LINK),
        ),
        _logoutItem(context)
      ],
    );
  }

  Widget _title() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, top: 8),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(900)),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(left: 8),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24, top: 8),
          child: Text(
            "My Account",
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontFamily: 'LatoBold'),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(
      BuildContext context, String title, String text, IconData icon,
      [Function? onPress]) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Card(
        elevation: 7,
        color: Colors.deepPurple,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: TextButton(
          onPressed: onPress as void Function()?,
          child: Wrap(
            children: [
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
                            _settingsIcon(icon),
                            _settingsItemContent(title, text),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 36,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsIcon(IconData icon) {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 64,
        width: 64,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Center(
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsItemContent(String title, String text) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, right: 3),
                    child: Text(
                      title,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'LatoBold',
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 4, right: 1),
                      child: Text(
                        text,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _logUserOut() {
    final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/log', (route) => false);
  }

  Widget _logoutItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: Card(
        elevation: 7,
        color: Colors.red,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: _logoutButton(),
      ),
    );
  }

  Widget _logoutButton() {
    return TextButton(
      onPressed: () => _logUserOut(),
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
                      _logoutButtonIcon(),
                      Expanded(
                        child: _logoutButtonText(),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 36,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _logoutButtonIcon() {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 64,
        width: 64,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Center(
            child: Icon(
              Icons.exit_to_app,
              color: Colors.red,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutButtonText() {
    return Padding(
      padding: EdgeInsets.only(left: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 3),
                  child: Text(
                    "Log Out",
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'LatoBold',
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
