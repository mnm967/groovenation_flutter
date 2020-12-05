import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {

  final List<String> items = <String>[
    'All Nearby Clubs',
    'Only Favourite Clubs',
    'Off',
  ];
  String dropdownValue = 'Off';

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
                                    padding: EdgeInsets.zero,
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
                                    padding:
                                        EdgeInsets.only(left: 12, right: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    child: Stack(
                                      children: [
                                        DropdownButton<String>(
                                          icon: Icon(Icons.arrow_drop_down,
                                              color: Colors.white),
                                          iconSize: 28,
                                          elevation: 16,
                                          style: TextStyle(
                                              color: Colors.deepPurple),
                                          isExpanded: true,
                                          underline: Container(
                                            height: 0,
                                            color: Colors.transparent,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              dropdownValue = newValue;
                                              print(dropdownValue);
                                            });
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
                                              dropdownValue,
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
                              Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Text(
                                    "Chat Notifications:",
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 18,
                                        color: Colors.white),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 12, right: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                    ),
                                    child: Stack(
                                      children: [
                                        DropdownButton<String>(
                                          icon: Icon(Icons.arrow_drop_down,
                                              color: Colors.white),
                                          iconSize: 28,
                                          elevation: 16,
                                          style: TextStyle(
                                              color: Colors.deepPurple),
                                          isExpanded: true,
                                          underline: Container(
                                            height: 0,
                                            color: Colors.transparent,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              dropdownValue = newValue;
                                              print(dropdownValue);
                                            });
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
                                              dropdownValue,
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