import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/ui/tickets/ticket_purchase_dialog.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  final Event event;
  EventPage(this.event);

  @override
  _EventPageState createState() => _EventPageState(event);
}

class _EventPageState extends State<EventPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  final Event event;
  _EventPageState(this.event);

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

  Function _showTicketPurchasePage() {
    return () {
      showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: Duration(milliseconds: 500),
        context: this.context,
        pageBuilder: (con, __, ___) {
          return TicketPurchaseDialog(event);
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

  _openClubPage(Club club) async {
    await _hideLoadingDialog();
    Navigator.pushNamed(context, '/club', arguments: club);
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _isLoadingVisible = false;

  Future<void> _showLoadingDialog(BuildContext context, String text) async {
    _isLoadingVisible = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(_keyLoader, text);
        });
  }

  Future<void> _hideLoadingDialog() async {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      await Future.delayed(Duration(seconds: 1));
    }

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  Future<void> _showAlertDialog(String title, String desc) async {
    await _hideLoadingDialog();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontFamily: 'Lato'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(desc, style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    final FavouritesEventsCubit favouritesEventsCubit =
        BlocProvider.of<FavouritesEventsCubit>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocListener<EventPageClubCubit, ClubsState>(
              listener: (BuildContext context, state) {
                if (state is ClubLoadedState) {
                  Club club = state.club;

                  _openClubPage(club);
                }

                if (state is ClubsErrorState) {
                  _showAlertDialog("Something Went Wrong",
                      "An error occured. Please check your connection and try again.");
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  BlocBuilder<FavouritesEventsCubit, EventsState>(
                      builder: (context, favouriteEventsState) {
                    bool eventIsFav =
                        favouritesEventsCubit.checkEventExists(event.eventID);

                    return SliverPersistentHeader(
                      delegate: MySliverAppBar(
                        expandedHeight: 392.0,
                        statusBarHeight: MediaQuery.of(context).padding.top,
                        imageUrl: event.imageUrl,
                        onTicketButtonClick: _showTicketPurchasePage(),
                        onClubButtonClick: () {
                          _showLoadingDialog(context, "Loading Club...");
                          final EventPageClubCubit eventPageClubCubit =
                              BlocProvider.of<EventPageClubCubit>(context);

                          eventPageClubCubit.getClub(event.clubID);
                        },
                        isEventLiked: eventIsFav,
                        onFavButtonClick: () {
                          if (favouritesEventsCubit
                              .checkEventExists(event.eventID)) {
                            favouritesEventsCubit.removeEvent(event);
                          } else
                            favouritesEventsCubit.addEvent(event);
                        },
                      ),
                      floating: false,
                      pinned: true,
                    );
                  }),
                  SliverToBoxAdapter(
                      child: Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.zero,
                                  child: Text(
                                    event.clubName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontFamily: 'LatoBold'),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    event.title,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 24,
                                        fontFamily: 'Lato'),
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    DateFormat("MMM dd, yyyy · HH:mm")
                                        .format(event.eventStartDate),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontFamily: 'Lato'),
                                  )),
                              Visibility(
                                  visible: event.isAdultOnly,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        "18+ Only",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 24,
                                            fontFamily: 'Lato'),
                                      ))),
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                        visible: event.webLink != null,
                                        child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                _launchURL(event.webLink);
                                              },
                                              constraints:
                                                  BoxConstraints.expand(
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
                                                      width: 1,
                                                      color: Colors.white)),
                                            ))),
                                    Visibility(
                                        visible: event.facebookLink != null,
                                        child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                _launchURL(event.facebookLink);
                                              },
                                              constraints:
                                                  BoxConstraints.expand(
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
                                                      width: 1,
                                                      color: Colors.white)),
                                            ))),
                                    Visibility(
                                        visible: event.twitterLink != null,
                                        child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                _launchURL(event.twitterLink);
                                              },
                                              constraints:
                                                  BoxConstraints.expand(
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
                                                      width: 1,
                                                      color: Colors.white)),
                                            ))),
                                    Visibility(
                                        visible: event.instagramLink != null,
                                        child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                _launchURL(event.instagramLink);
                                              },
                                              constraints:
                                                  BoxConstraints.expand(
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
                                                      width: 1,
                                                      color: Colors.white)),
                                            ))),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 84),
                                  child: Text(
                                    event.description,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontFamily: 'LatoLight'),
                                  )),
                            ],
                          )))
                ],
              )),
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

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double statusBarHeight;
  final String imageUrl;
  final Function onTicketButtonClick;
  final Function onClubButtonClick;
  final Function onFavButtonClick;
  final bool isEventLiked;

  MySliverAppBar({
    @required this.expandedHeight,
    @required this.statusBarHeight,
    @required this.imageUrl,
    @required this.onTicketButtonClick,
    @required this.onClubButtonClick,
    @required this.onFavButtonClick,
    @required this.isEventLiked,
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
                    imageUrl: imageUrl,
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

  Stack topAppBar(BuildContext context, double shrinkOffset) =>
      Stack(children: [
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
                                              onPressed: () =>
                                                  onFavButtonClick(),
                                              child: Icon(
                                                isEventLiked
                                                    ? Icons.favorite_outlined
                                                    : Icons.favorite_border,
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
                                            padding: EdgeInsets.zero,
                                            decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(90)),
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
