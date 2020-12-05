import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
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

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                  child: SafeArea(
                      child: Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 16, right: 16),
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
                                            borderRadius:
                                                BorderRadius.circular(900)),
                                        child: FlatButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {},
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      )),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 24, top: 8),
                                      child: Text(
                                        "Conversations",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontFamily: 'LatoBold'),
                                      )),
                                ],
                              ),
                              ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(top: 24, bottom: 8),
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return conversationItem(context);
                                  }),
                            ],
                          ))))
            ],
          ),
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
    );
  }

  Widget conversationItem(BuildContext context) {
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
                                          child: FlatButton(
                                              onPressed: () {
                                                print("object");
                                              },
                                              child: Container()),
                                        ))),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
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
                                                Text(
                                                  "Saturday",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontFamily: 'LatoLight',
                                                      fontSize: 16,
                                                      color: Colors.white),
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
                                                    Visibility(
                                                        visible: false,
                                                        child: Icon(Icons.check,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.4))),
                                                    Expanded(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 4,
                                                                    right: 1),
                                                            child: Text(
                                                              "Yo wassup man. Yesterday was lit man",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Lato',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.4)),
                                                            ))),
                                                    Visibility(
                                                        visible: true,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 2,
                                                                  left: 3),
                                                          child: SizedBox(
                                                            height: 24,
                                                            width: 24,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Container(
                                                                child: Center(
                                                                  child: Text(
                                                                    "1",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Lato',
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                  ],
                                                )),
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
