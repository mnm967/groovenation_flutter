import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/ui/tickets/ticket_purchase_dialog.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
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

  Function showTicketPurchasePage() {
    return () {
      showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: Duration(milliseconds: 500),
        context: this.context,
        pageBuilder: (con, __, ___) {
          return TicketPurchaseDialog();
        },
        transitionBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(
                CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
            child: child,
          );
        },
      );
    };
  }

  Function openClubPage() {
    return () {
      Navigator.pushNamed(context, '/club');
    };
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
              SliverPersistentHeader(
                delegate: MySliverAppBar(
                    expandedHeight: 392.0,
                    statusBarHeight: MediaQuery.of(context).padding.top,
                    onTicketButtonClick: showTicketPurchasePage(),
                    onClubButtonClick: openClubPage()),
                floating: false,
                pinned: true,
              ),
              SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.zero,
                              child: Text(
                                "Helix After Party",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontFamily: 'LatoBold'),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "Jive Lounge",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 24,
                                    fontFamily: 'Lato'),
                              )),
                          Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                "Sep 19, 2020 · 20:00",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'Lato'),
                              )),
                          Visibility(
                              visible: true,
                              child: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "18+ Only",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 24,
                                        fontFamily: 'Lato'),
                                  ))),
                          // Padding(
                          //   padding: EdgeInsets.only(top: 8),
                          //   child: Padding(
                          //       padding: EdgeInsets.only(top: 8, right: 8),
                          //       child: Container(
                          //         padding: EdgeInsets.zero,
                          //         decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          //         ),
                          //         child: FlatButton(
                          //           onPressed: () {},
                          //           child: Container(
                          //               height: 56,
                          //               child: Align(
                          //                 alignment: Alignment.center,
                          //                 child: Text(
                          //                   "Visit Website",
                          //                   style: TextStyle(
                          //                       fontFamily: 'LatoBold',
                          //                       color: Colors.deepPurple.withOpacity(0.8),
                          //                       fontSize: 18),
                          //                 ),
                          //               )),
                          //         ),
                          //       )),
                          // ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.globeAfrica,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.facebookF,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.twitter,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.instagram,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 84),
                              child: Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'LatoLight'),
                              )),
                        ],
                      )))
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
                        color: Colors.deepPurple.withOpacity(0.5),
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
                        color: Colors.white.withOpacity(0.5),
                        size: 36,
                      ),
                    ),
                  ),
                )))
      ],
    );
  }

  final List<String> items = <String>[
    '1 Person',
    '2 People',
    '3 People',
    '4 People'
  ];
  String dropdownValue = '1 Person';

  final List<String> typeItems = <String>[
    'General Admission',
    'Special Admission',
    'VIP Admission',
    'Golden Circle'
  ];
  String typeValue = 'Special Admission';

  Widget ticketPurchasePage(context) {
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
                  child: ticketPageText("Tickets Currently Available", "4"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Adults Only", "Yes"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Type",
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8, right: 8),
                            child: Container(
                              padding: EdgeInsets.only(left: 12, right: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1.0, color: Colors.white),
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
                                    style: TextStyle(color: Colors.deepPurple),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 0,
                                      color: Colors.transparent,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        typeValue = newValue;
                                        print(typeValue);
                                      });
                                    },
                                    itemHeight: 56,
                                    value: typeValue,
                                    items: typeItems
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
                                        typeValue,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "No. of People",
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8, right: 8),
                            child: Container(
                              padding: EdgeInsets.only(left: 12, right: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1.0, color: Colors.white),
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
                                    style: TextStyle(color: Colors.deepPurple),
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
                                    value: dropdownValue,
                                    items: items.map<DropdownMenuItem<String>>(
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
                            ))
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: purchasePageText("Type", "General Admission", false),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: purchasePageText("No. of People", "1", false),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: purchasePageText("Total Price", "R500", true),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: FlatButton(
                          onPressed: () {},
                          child: Container(
                              height: 56,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Purchase",
                                  style: TextStyle(
                                      fontFamily: 'LatoBold',
                                      color: Colors.deepPurple,
                                      fontSize: 18),
                                ),
                              )),
                        ),
                      )),
                ),
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

  Widget purchasePageText(title, text, isBold) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: isBold ? 'LatoBlack' : 'Lato',
                fontSize: 20,
                color: Colors.white.withOpacity(0.4)),
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        text,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: isBold ? 'LatoBlack' : 'Lato',
                            fontSize: 22,
                            color: Colors.white),
                      )))),
        ]);
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double statusBarHeight;
  final Function onTicketButtonClick;
  final Function onClubButtonClick;

  MySliverAppBar({
    @required this.expandedHeight,
    @required this.statusBarHeight,
    @required this.onTicketButtonClick,
    @required this.onClubButtonClick,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        height: expandedHeight,
        child: Stack(children: [
          Container(
              height: (expandedHeight - 36),
              child: Stack(
                fit: StackFit.expand,
                overflow: Overflow.visible,
                children: [
                  Positioned.fill(
                      child: OptimizedCacheImage(
                      imageUrl: "https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                     fit: BoxFit.cover,
                  )),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  SafeArea(child: topAppBar(context, shrinkOffset)),
                ],
              )),
          Container(
            height: (expandedHeight),
            width: double.infinity,
            child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          height: 72,
                          width: 72,
                          child: Card(
                            elevation: 6.0,
                            clipBehavior: Clip.antiAlias,
                            shape: CircleBorder(),
                            color: Colors.deepPurple,
                            child: Container(
                                child: FlatButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: onTicketButtonClick,
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.ticketAlt,
                                        color: Colors.white,
                                      ),
                                    ))),
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          height: 72,
                          width: 72,
                          child: Card(
                            elevation: 6.0,
                            clipBehavior: Clip.antiAlias,
                            shape: CircleBorder(),
                            color: Colors.deepPurple,
                            child: Container(
                                child: FlatButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: onClubButtonClick,
                                    child: Center(
                                      child: Icon(
                                        Icons.local_bar,
                                        color: Colors.white,
                                      ),
                                    ))),
                          ),
                        )),
                  ],
                )),
          )
        ]));
  }

  Stack topAppBar(BuildContext context, double shrinkOffset) => Stack(children: [
        Row(children: [
          Expanded(
            child: Container(
                child: Stack(
              children: [
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
                    child: Container(
                        padding: EdgeInsets.zero,
                        child: Container(
                            width: double.infinity,
                            height: expandedHeight,
                            child: Stack(
                              children: [
                                Opacity(
                                    opacity:
                                        (1 - shrinkOffset / expandedHeight),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 16, right: 16),
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(9)),
                                            child: FlatButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {},
                                              child: Icon(
                                                Icons.favorite_border,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          )),
                                    )),
                                Opacity(
                                    opacity:
                                        (1 - shrinkOffset / expandedHeight),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 16, right: 16),
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(900)),
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
                                    )),
                              ],
                            ))),
                  ),
                ),
              ],
            )),
          ),
        ]),
      ]);

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => statusBarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
