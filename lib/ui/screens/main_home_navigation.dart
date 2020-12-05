import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/ui/clubs/clubs_home.dart';
import 'package:groovenation_flutter/ui/events/events_home.dart';
import 'package:groovenation_flutter/ui/profile/profile_home.dart';
import 'package:groovenation_flutter/ui/social/social_home.dart';
import 'package:groovenation_flutter/ui/tickets/tickets_home.dart';

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
                          title: new Text('Events'),
                        ),
                        BottomNavigationBarItem(
                          icon: new Icon(Icons.local_bar),
                          title: new Text('Clubs'),
                        ),
                        BottomNavigationBarItem(
                          icon: new Icon(FontAwesomeIcons.ticketAlt),
                          title: new Text('Tickets'),
                        ),
                        BottomNavigationBarItem(
                            icon: FaIcon(FontAwesomeIcons.users),
                            title: Text('Social')),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.person_pin),
                            title: Text('Proile')),
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
