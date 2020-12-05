import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:optimized_cached_image/image_provider/optimized_cached_image_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketsHomePage extends StatefulWidget {
  final _TicketsHomePageState state = _TicketsHomePageState();

  void runBuild() {
    state.runBuild();
  }

  @override
  _TicketsHomePageState createState() {
    return state;
  }
}

class _TicketsHomePageState extends State<TicketsHomePage> {
  bool isFirstView = true;

  runBuild() {
    if (isFirstView) {
      print("Running Build: TicketsHome");
      isFirstView = false;
    }
  }

  final _upcomingRefreshController = RefreshController(initialRefresh: false);
  final _completedRefreshController = RefreshController(initialRefresh: false);

  final ScrollController _upcomingScrollController = new ScrollController();
  final ScrollController _completedScrollController = new ScrollController();

  void setListScrollListener(
      ScrollController controller, RefreshController refreshController) {
    controller.addListener(() {
      if (controller.position.pixels >=
          (controller.position.maxScrollExtent - 256)) {
        if (refreshController.footerStatus == LoadStatus.idle) {
          print("Start Loading");
          refreshController.requestLoading(needMove: false);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setListScrollListener(
        _upcomingScrollController, _upcomingRefreshController);
    setListScrollListener(
        _completedScrollController, _completedRefreshController);
  }

  final FlareControls flareControls = FlareControls();

  @override
  void dispose() {
    _upcomingScrollController.dispose();
    _completedScrollController.dispose();

    _upcomingRefreshController.dispose();
    _completedRefreshController.dispose();
    super.dispose();
  }

  openSearchPage() {
    Navigator.pushNamed(context, '/search');
  }



  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                openSearchPage();
              },
              child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white.withOpacity(0.2)),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Text(
                            "Search",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontFamily: 'Lato',
                                fontSize: 17),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: Icon(
                              Icons.search,
                              size: 28,
                              color: Colors.white.withOpacity(0.5),
                            )),
                      ),
                    ],
                  ))),
        ),
        TabBar(
          tabs: [
            Tab(
              icon: Icon(FontAwesomeIcons.ticketAlt),
              text: "Upcoming",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.checkCircle),
              text: "Completed",
            ),
          ],
        )
      ]);

  //TODO Remove After Testing
  int upcomingCount = 8;
  int completedCount = 8;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                topAppBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      SmartRefresher(
                        controller: _upcomingRefreshController,
                        header: WaterDropMaterialHeader(),
                        footer: ClassicFooter(
                          textStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              fontFamily: 'Lato'),
                          noDataText: "You've reached the end of the line",
                          failedText: "Something Went Wrong",
                        ),
                        onLoading: () {
                          print("Started Loading");
                          Future.delayed(const Duration(seconds: 5), () {
                            setState(() {
                              upcomingCount = upcomingCount + 4;
                            });
                            _upcomingRefreshController.loadComplete();
                            print("Finished Loading");
                          });
                        },
                        enablePullUp: true,
                        child: upcomingList(),
                      ),
                      SmartRefresher(
                        controller: _completedRefreshController,
                        header: WaterDropMaterialHeader(),
                        footer: ClassicFooter(
                          textStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              fontFamily: 'Lato'),
                          noDataText: "You've reached the end of the line",
                          failedText: "Something Went Wrong",
                        ),
                        onLoading: () {
                          print("Started Loading");
                          Future.delayed(const Duration(seconds: 5), () {
                            setState(() {
                              completedCount = completedCount + 4;
                            });
                            _completedRefreshController.loadComplete();
                            print("Finished Loading");
                          });
                        },
                        enablePullUp: true,
                        child: completedList(),
                      ),
                    ],
                  ),
                )
              ],
            )));
  }

  Widget upcomingList() {
    return ListView.builder(
        controller: _upcomingScrollController,
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 12), child: ticketItem(context));
        });
  }

  Widget completedList() {
    return ListView.builder(
        controller: _completedScrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ticketItemCompleted(context));
        });
  }

  Widget ticketItem(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: FlatButton(
          onPressed: () {
            showGeneralDialog(
              barrierLabel: "Barrier",
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.1),
              transitionDuration: Duration(milliseconds: 500),
              context: context,
              pageBuilder: (con, __, ___) {
                return SafeArea(
                  bottom: false,
                  child: Container(
                    height: double.infinity,
                    child: SizedBox.expand(
                      child: ticketPage(con),
                    ),
                    margin: EdgeInsets.only(
                        top: 24, bottom: 24, left: 24, right: 24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              transitionBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                      .animate(CurvedAnimation(
                          parent: anim, curve: Curves.elasticOut)),
                  child: child,
                );
              },
            );
          },
          padding: EdgeInsets.zero,
          child: Wrap(children: [
            Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 164,
                              width: 128,
                              child: Stack(
                                children: [
                                  Image(
                                    height: double.infinity,
                                    width: 128,
                                    fit: BoxFit.cover,
                                    image: OptimizedCacheImageProvider(
                                        'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'),
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(0.25),
                                    child: Center(
                                      child: new FaIcon(
                                        FontAwesomeIcons.qrcode,
                                        size: 72,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 20, top: 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Helix After Party",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'LatoBold',
                                        fontSize: 22,
                                        color: Colors.white),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                        "Club Groova",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 18,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        "Sep 19, 2020 · 20:00",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        "•  General Admission",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        "•  1 Person",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ],
            )
          ])),
    );
  }

  Widget ticketItemCompleted(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: FlatButton(
          onPressed: () {
            showGeneralDialog(
              barrierLabel: "Barrier",
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.1),
              transitionDuration: Duration(milliseconds: 500),
              context: context,
              pageBuilder: (con, __, ___) {
                return SafeArea(
                  bottom: false,
                  child: Container(
                    height: double.infinity,
                    child: SizedBox.expand(
                      child: ticketPage(con),
                    ),
                    margin: EdgeInsets.only(
                        top: 24, bottom: 24, left: 24, right: 24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              transitionBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                      .animate(CurvedAnimation(
                          parent: anim, curve: Curves.elasticOut)),
                  child: child,
                );
              },
            );
          },
          padding: EdgeInsets.zero,
          child: Wrap(children: [
            Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 164,
                              width: 128,
                              child: Stack(
                                children: [
                                  Image(
                                    height: double.infinity,
                                    width: 128,
                                    fit: BoxFit.cover,
                                    image: OptimizedCacheImageProvider(
                                        'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'),
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(0.25),
                                    child: Center(
                                      child: new FaIcon(
                                        FontAwesomeIcons.checkCircle,
                                        size: 72,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 20, top: 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Helix After Party",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'LatoBold',
                                        fontSize: 22,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.white),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                        "Club Groova",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 18,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        "Sep 19, 2020 · 20:00",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        "•  General Admission",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        "•  1 Person",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ],
            )
          ])),
    );
  }

  Widget ticketPage(context) {
    return Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 24, bottom: 16, right: 16, left: 24),
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: ticketPageText(
                                "Event Name", "Helix After Party"))),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Event Club", "Jive Lounge"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Date", "Sep 19, 2020 · 20:00"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child:
                      ticketPageText("Ticket ID", "dgh67cndgs5yt67dky93g7j58"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Type", "General Admission"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("No. of People", "1"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: ticketPageText("Cost", "R50"))),
                      RawMaterialButton(
                        onPressed: () {},
                        constraints:
                            BoxConstraints.expand(width: 56, height: 56),
                        elevation: 0,
                        child: Center(
                            child: Icon(
                          FontAwesomeIcons.shareAlt,
                          color: Colors.white,
                          size: 22.0,
                        )),
                        padding: EdgeInsets.all(16.0),
                        shape: CircleBorder(
                            side: BorderSide(width: 1, color: Colors.white)),
                      ),
                      RawMaterialButton(
                        onPressed: () {},
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        child: Center(
                            child: FaIcon(
                          FontAwesomeIcons.mapMarkedAlt,
                          color: Colors.white,
                          size: 24.0,
                        )),
                        padding: EdgeInsets.all(16.0),
                        shape: CircleBorder(
                            side: BorderSide(width: 1, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 36, bottom: 64),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: QrImage(
                          data: "This QR code has an embedded image as well",
                          version: QrVersions.auto,
                        ),
                      ),
                    ))
              ]),
        ));
  }

  Widget ticketPageText(title, text) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: Colors.white.withOpacity(0.4)),
          ),
          Padding(
              padding: EdgeInsets.only(top: 1, right: 8),
              child: Text(
                text,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
              )),
        ]);
  }
}
