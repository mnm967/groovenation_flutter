import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:location/location.dart';
import 'package:optimized_cached_image/image_provider/optimized_cached_image_provider.dart';

class CityPickerPage extends StatefulWidget {
  @override
  _CityPickerPageState createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  Future<void> _showPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Location Permission",
            style: TextStyle(fontFamily: 'Lato'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "Optional: GrooveNation can use your location to provide more accurate data on nearby clubs and events. Will you allow GrooveNation to access your location when available?",
                    style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () {
                sharedPrefs.userCity = selectedCity;
                if (sharedPrefs.username != null)
                  //Navigator.pushReplacementNamed(context, '/main');
                  Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new MainNavigationScreen()));
                else
                  Navigator.pushReplacementNamed(
                      context, '/create_username'); //TODO Create Username Page
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () async {
                Location location = new Location();
                await location.requestPermission();

                sharedPrefs.userCity = selectedCity;
                if (sharedPrefs.username != null)
                  //Navigator.pushReplacementNamed(context, '/main');
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new MainNavigationScreen()));
                else
                  Navigator.pushReplacementNamed(
                      context, '/create_username'); //TODO Create Username Page
              },
            ),
          ],
        );
      },
    );
  }

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

  String selectedCity;

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
                    Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Text(
                          "Choose A City",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'LatoBold'),
                        )),
                    Visibility(
                      child: topAppBar(),
                      visible: false,
                    ),
                    ListView(
                      padding: EdgeInsets.only(top: 12),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 4),
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
                selectedCity = CITY_JOHANNESBURG;
                _showPermissionDialog();
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
