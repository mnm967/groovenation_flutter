import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 30) {
        if (_scrollToTopVisible != false) {
          setState(() {
            _scrollToTopVisible = false;
          });
        }
      } else {
        if (_scrollToTopVisible != true) {
          setState(() {
            _scrollToTopVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.2)),
            child: TextField(
              keyboardType: TextInputType.multiline,
              autofocus: true,
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
                        color: Colors.white,
                        size: 28,
                      )),
                  prefixIcon: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.only(left: 16, right: 24),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ))),
            ),
          ),
        ),
        TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.whatshot),
              text: "Events",
            ),
            Tab(
              icon: Icon(Icons.local_bar),
              text: "Clubs",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.ticketAlt),
              text: "Tickets",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.users),
              text: "People",
            ),
          ],
        )
      ]);

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: DefaultTabController(
          length: 4,
          child: Stack(
            children: [
              Column(
                children: [
                  topAppBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Icon(Icons.directions_transit, color: Colors.white),
                        Icon(Icons.directions_transit, color: Colors.white),
                        Icon(Icons.directions_transit, color: Colors.white),
                        Padding(
                            padding: EdgeInsets.all(16),
                            child: Align(
                              child: profileItem(context),
                              alignment: Alignment.topCenter,
                            )),
                      ],
                    ),
                  )
                ],
              ),
              AnimatedOpacity(
                  opacity: _scrollToTopVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16, right: 16),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(9)),
                          child: FlatButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _scrollController.animateTo(
                                0.0,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white.withOpacity(0.7),
                              size: 36,
                            ),
                          ),
                        ),
                      )))
            ],
          )),
    );
  }

  Widget profileItem(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 4,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {},
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
                                          backgroundImage: OptimizedCacheImageProvider(
                                              'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
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
                                                      "professor_mnm967",
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
