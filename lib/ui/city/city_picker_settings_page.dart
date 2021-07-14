import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class CityPickerSettingsPage extends StatefulWidget {
  @override
  _CityPickerSettingsPageState createState() => _CityPickerSettingsPageState();
}

class _CityPickerSettingsPageState extends State<CityPickerSettingsPage> {
  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.2)),
            child: TextField(
              keyboardType: TextInputType.multiline,
              autofocus: false,
              cursorColor: Colors.white.withOpacity(0.7),
              style: TextStyle(
                  fontFamily: 'Lato', color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                  hintMaxLines: 3,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.2),
                        size: 28,
                      ))),
            ),
          ),
        ),
      ]);

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
                padding: EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 16, top: 16),
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
                            padding: EdgeInsets.only(left: 36, top: 16),
                            child: Text(
                              "Choose A City",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'LatoBold'),
                            )),
                      ],
                    ),
                    Visibility(
                        visible: false,
                        child: Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: topAppBar(),
                        )),
                    ListView(
                      padding: EdgeInsets.only(top: 16),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            child: Align(
                              child: cityItem(context, "Johannesburg",
                                  "https://media.threatpost.com/wp-content/uploads/sites/103/2019/10/30083110/johannesburg-e1572438686227.jpg"),
                              alignment: Alignment.topCenter,
                            )),
                      ],
                    )
                  ],
                )))
      ],
    ));
  }

  String _selectedCity = sharedPrefs.userCity;
  _saveSelectedCity(BuildContext c) {
    sharedPrefs.userCity = _selectedCity;
    Navigator.pop(c);
  }

  Widget cityItem(BuildContext context, String name, String imageUrl) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 4,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {
                _selectedCity = CITY_JOHANNESBURG;
                _saveSelectedCity(context);
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
                                          backgroundColor:
                                              Colors.purple.withOpacity(0.5),
                                          backgroundImage:
                                              OptimizedCacheImageProvider(
                                                  imageUrl),
                                        ))),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 16),
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
                                                      name,
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'LatoBold',
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )))
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
