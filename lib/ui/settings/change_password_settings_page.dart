import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangePasswordSettingsPage extends StatefulWidget {
  @override
  _ChangePasswordSettingsPageState createState() => _ChangePasswordSettingsPageState();
}

class _ChangePasswordSettingsPageState extends State<ChangePasswordSettingsPage> {
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
                              "Change Password",
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
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Lato',
                              ),
                              autofocus: true,
                              obscureText: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "Enter Current Password",
                                labelStyle: TextStyle(
                                    fontFamily: 'Lato', color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: const BorderSide(
                                        color: Colors.white, width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: const BorderSide(
                                        color: Color(0xffE65AB9), width: 1.0)),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Lato',
                              ),
                              obscureText: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "Enter New Password",
                                labelStyle: TextStyle(
                                    fontFamily: 'Lato', color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: const BorderSide(
                                        color: Colors.white, width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: const BorderSide(
                                        color: Color(0xffE65AB9), width: 1.0)),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Lato',
                              ),
                              obscureText: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "Confirm New Password",
                                labelStyle: TextStyle(
                                    fontFamily: 'Lato', color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: const BorderSide(
                                        color: Colors.white, width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: const BorderSide(
                                        color: Color(0xffE65AB9), width: 1.0)),
                              )),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 24, bottom: 24),
                            child: Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: FlatButton(
                                onPressed: () {},
                                child: Container(
                                    height: 64,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Save Changes",
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Colors.deepPurple,
                                            fontSize: 18),
                                      ),
                                    )),
                              ),
                            )),
                      ],
                    ),
                  ],
                )))
      ],
    ));
  }
}
