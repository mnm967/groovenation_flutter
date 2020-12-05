import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
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
                              "Profile",
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
                      padding: EdgeInsets.only(top: 56, bottom: 8),
                      children: [
                        Align(
                          child: FlatButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                                height: 116,
                                width: 116,
                                child: CircleAvatar(
                                  backgroundImage: OptimizedCacheImageProvider(
                                      'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                                  child: Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        FontAwesomeIcons.penAlt,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 56),
                          child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Lato',
                              ),
                              readOnly: true,
                              initialValue: "professor_mnm967",
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "Public Username",
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
                                        color: Colors.white, width: 1.0)),
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
                              initialValue: "mothusom68@gmail.com",
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "Email Address",
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
                              initialValue: "Mothuso",
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "First Name",
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
                              initialValue: "Malunga",
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                labelText: "Last Name",
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
                            child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: AspectRatio(
                                  aspectRatio: 1 / 0.8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: OptimizedCacheImageProvider(
                                              //'https://jakecoker.files.wordpress.com/2018/09/default-landscapeipad.png?w=1024&h=768&crop=1'),
                                              'https://images.pexels.com/photos/2204724/pexels-photo-2204724.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500'),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.3),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                print("");
                                              },
                                              constraints:
                                                  BoxConstraints.expand(
                                                      width: 108, height: 108),
                                              elevation: 0,
                                              child: Center(
                                                  child: Icon(
                                                FontAwesomeIcons.penAlt,
                                                color: Colors.white,
                                                size: 32.0,
                                              )),
                                              shape: CircleBorder(
                                                  side: BorderSide(
                                                      width: 1,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 36),
                                            child: Text(
                                              "Change Cover Image",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Lato',
                                                  fontSize: 36),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ))),
                        Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/change_password_settings');
                                },
                                child: Container(
                                    height: 64,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Change Password",
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    )),
                              ),
                            )),
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
