import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovenation_flutter/constants/settings_strings.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final List<String> items = <String>[
    NOTIFICATION_ALL_NEARBY_OPTION,
    NOTIFICATION_FAVOURITE_ONLY_OPTION,
    NOTIFICATION_OFF_OPTION,
  ];

  String dropdownValue = sharedPrefs.notificationSetting;

  final List<String> chatItems = <String>[
    CHAT_NOTIFICATION_ON_OPTION,
    CHAT_NOTIFICATION_OFF_OPTION,
  ];
  String chatDropdownValue = sharedPrefs.chatNotificationSetting;

  _saveNotificationSetting() {
    switch (dropdownValue) {
      case NOTIFICATION_ALL_NEARBY:
        _unsubscribeFavouriteClubs();
        FirebaseMessaging.instance.subscribeToTopic("new_event_topic");
        sharedPrefs.notificationSetting = NOTIFICATION_ALL_NEARBY;
        break;
      case NOTIFICATION_FAVOURITE_ONLY:
        _subscribeFavouriteClubs();
        FirebaseMessaging.instance.unsubscribeFromTopic("new_event_topic");
        sharedPrefs.notificationSetting = NOTIFICATION_FAVOURITE_ONLY;
        break;
      case NOTIFICATION_OFF:
        _unsubscribeFavouriteClubs();
        FirebaseMessaging.instance.unsubscribeFromTopic("new_event_topic");
        sharedPrefs.notificationSetting = NOTIFICATION_OFF;
        break;
      default:
    }
    setState(() {});
  }

  _unsubscribeFavouriteClubs() {
    List<String> clubIds = sharedPrefs.favouriteClubIds;
    clubIds.forEach((element) {
      FirebaseMessaging.instance
          .unsubscribeFromTopic("favourite_club_topic-$element");
    });
  }

  _subscribeFavouriteClubs() {
    List<String> clubIds = sharedPrefs.favouriteClubIds;
    clubIds.forEach((element) {
      FirebaseMessaging.instance
          .subscribeToTopic("favourite_club_topic-$element");
    });
  }

  String getCurrentValue() {
    switch (dropdownValue) {
      case NOTIFICATION_ALL_NEARBY:
        return NOTIFICATION_ALL_NEARBY_OPTION;
        break;
      case NOTIFICATION_FAVOURITE_ONLY:
        return NOTIFICATION_FAVOURITE_ONLY_OPTION;
        break;
      case NOTIFICATION_OFF:
        return NOTIFICATION_OFF_OPTION;
        break;
      default:
        return NOTIFICATION_ALL_NEARBY_OPTION;
    }
  }

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
                              "Notifications",
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
                        padding: EdgeInsets.only(top: 36, bottom: 8),
                        children: [
                          Text(
                            "New Event Notifications:",
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 18,
                                color: Colors.white),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Container(
                                padding: EdgeInsets.only(left: 12, right: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0, color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Stack(
                                  children: [
                                    DropdownButton<String>(
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Colors.white),
                                      iconSize: 28,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: Colors.deepPurple),
                                      isExpanded: true,
                                      underline: Container(
                                        height: 0,
                                        color: Colors.transparent,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          if(newValue == NOTIFICATION_ALL_NEARBY_OPTION) dropdownValue = NOTIFICATION_ALL_NEARBY;
                                          else if(newValue == NOTIFICATION_FAVOURITE_ONLY_OPTION) dropdownValue = NOTIFICATION_FAVOURITE_ONLY;
                                          else dropdownValue = NOTIFICATION_OFF;
                                        });

                                        _saveNotificationSetting();
                                      },
                                      itemHeight: 56,
                                      value: null,
                                      items: items
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                              style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  color: Colors.deepPurple,
                                                  fontSize: 18)),
                                        );
                                      }).toList(),
                                    ),
                                    Container(
                                      height: 56,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          getCurrentValue(),
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ]),
                  ],
                )))
      ],
    ));
  }
}
