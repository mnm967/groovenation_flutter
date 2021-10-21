import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/settings_strings.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/chat_cubit.dart';
import 'package:groovenation_flutter/ui/clubs/clubs_home.dart';
import 'package:groovenation_flutter/ui/events/events_home.dart';
import 'package:groovenation_flutter/ui/profile/profile_home.dart';
import 'package:groovenation_flutter/ui/social/social_home.dart';
import 'package:groovenation_flutter/ui/tickets/tickets_home.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int index = 0;

  final EventsHomePage page1 = EventsHomePage(1);
  final ClubsHomePage page2 = ClubsHomePage();
  final TicketsHomePage page3 = TicketsHomePage();
  final SocialHomePage page4 = SocialHomePage();
  final ProfileHomePage page5 = ProfileHomePage();

  @override
  void initState() {
    super.initState();
    final ConversationsCubit conversationsCubit =
        BlocProvider.of<ConversationsCubit>(context);

    conversationsCubit.init(context);

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((value) async {
      Dio().post("$API_HOST/users/fcm/token",
          data: {"userId": sharedPrefs.userId, "token": value});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data.toString() == "{}") return;

      var data = message.data;

      conversationsCubit.updateConversation(data);
    });

    if (sharedPrefs.notificationSetting == NOTIFICATION_ALL_NEARBY)
      FirebaseMessaging.instance.subscribeToTopic("new_event_topic");
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 75),
          child: Container(
            child: Stack(
              children: <Widget>[
                navPageItem(0, page1),
                navPageItem(1, page2),
                navPageItem(2, page3),
                navPageItem(3, page4),
                navPageItem(4, page5),
              ],
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: Colors.transparent),
                child: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: BottomNavigationBar(
                      currentIndex: index,
                      onTap: (int index) {
                        // if (index != 4)
                        setState(() {
                          this.index = index;
                        });
                        switch (index) {
                          case 0:
                            page1.runBuild();
                            return;
                          case 1:
                            page2.runBuild();
                            return;
                          case 2:
                            page3.runBuild();
                            return;
                          case 3:
                            page4.runBuild();
                            return;
                          case 4:
                            page5.runBuild();
                            // Navigator.push(
                            //     context,
                            //     new MaterialPageRoute(
                            //         builder: (context) =>
                            //             new SettingsPageScreen()));
                            // Navigator.pushReplacementNamed(
                            //     context, '/settings');

                            return;
                        }
                      },
                      backgroundColor: Colors.transparent,
                      selectedItemColor: Color(0xffE65AB9),
                      unselectedItemColor: Colors.white.withOpacity(0.5),
                      showUnselectedLabels: true,
                      elevation: 0,
                      selectedFontSize: 16,
                      unselectedFontSize: 14,
                      iconSize: 28,
                      selectedLabelStyle: TextStyle(fontFamily: 'LatoBold'),
                      unselectedLabelStyle: TextStyle(fontFamily: 'Lato'),
                      items: [
                        BottomNavigationBarItem(
                          icon: new Icon(Icons.whatshot),
                          label: 'Events',
                        ),
                        BottomNavigationBarItem(
                          icon: new Icon(Icons.local_bar),
                          label: 'Clubs',
                        ),
                        BottomNavigationBarItem(
                          icon: new Icon(FontAwesomeIcons.ticketAlt),
                          label: 'Tickets',
                        ),
                        BottomNavigationBarItem(
                            icon: FaIcon(FontAwesomeIcons.users),
                            label: 'Social'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.person_pin),
                            label: 'Profile'),
                        // BottomNavigationBarItem(
                        //     icon: Icon(Icons.settings),
                        //     title: Text('Settings')),
                      ],
                    )))),
      ],
    );
  }

  Widget navPageItem(itemIndex, child) {
    return new Offstage(
      offstage: index != itemIndex,
      child: new TickerMode(
        enabled: index == itemIndex,
        child: child,
      ),
    );
  }
}
