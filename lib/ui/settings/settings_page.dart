import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/auth_cubit.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
        child: CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 8, top: 8),
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(900)),
                              child: FlatButton(
                                padding: EdgeInsets.only(left: 8),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            )),
                        Padding(
                            padding: EdgeInsets.only(left: 24, top: 8),
                            child: Text(
                              "My Account",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'LatoBold'),
                            )),
                      ],
                    ),
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 24, bottom: 8),
                      children: [
                        settingsItem(context, "Profile",
                            "Edit your Profile settings", Icons.person, () {
                          // Navigator.pushNamed(context, '/profile_settings');
                          Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        new ProfileSettingsPageScreen()));
                        }),
                        // settingsItem(
                        //     context,
                        //     "Following",
                        //     "View people you are following",
                        //     Icons.people_outline, () {
                        //   Navigator.pushNamed(context, '/following');
                        // }),
                        settingsItem(
                            context,
                            "Change City",
                            "Look for clubs and events in a different city",
                            Icons.location_city, () {
                          //Navigator.pushNamed(context, '/city_picker_settings');
                          Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        new CityPickerSettingsPageScreen()));
                        }),
                        // settingsItem(
                        //   context,
                        //   "Followers",
                        //   "View your followers",
                        //   Icons.favorite,
                        //   (){}
                        // ),
                        settingsItem(
                            context,
                            "Notifications",
                            "Change your Notification settings",
                            Icons.notifications, () {
                          // Navigator.pushNamed(
                          //     context, '/notification_settings');
                          Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        new NotificationSettingsPageScreen()));
                        }),
                        settingsItem(
                            context,
                            "Contact Us",
                            "Have a question or an issue? Feel free to contact us",
                            Icons.chat,
                            () {}),
                        settingsItem(
                            context,
                            "About",
                            "Learn more about GrooveNation",
                            Icons.local_bar,
                            () {}),
                        settingsItem(
                            context,
                            "Terms and Conditions",
                            "Read our Terms and Conditions",
                            Icons.description,
                            () {}),
                        settingsItem(
                            context,
                            "Privacy Policy",
                            "Read our Privacy Policy",
                            Icons.verified_user,
                            () {}),
                        logoutItem(context)
                      ],
                    ),
                  ],
                )))
      ],
    ));
  }

  Widget settingsItem(BuildContext context, String title, String text,
      IconData icon, Function onPress) {
    return Padding(
        padding: EdgeInsets.only(top: 12),
        child: Card(
          elevation: 7,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: onPress,
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
                                            color: Colors.deepPurple,
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
                                                      title,
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
                                                              text,
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
                                  Icons.chevron_right,
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

  _logUserOut() {
    final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget logoutItem(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: Card(
          elevation: 7,
          color: Colors.red,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () => _logUserOut(),
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
                                            Icons.exit_to_app,
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
                                                      "Log Out",
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
                                          ],
                                        ))),
                                Icon(
                                  Icons.chevron_right,
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
