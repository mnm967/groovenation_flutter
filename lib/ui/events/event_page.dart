import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/event/event_club_cubit.dart';
import 'package:groovenation_flutter/cubit/event/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/ui/events/widgets/event_page_collapsing_app_bar.dart';
import 'package:groovenation_flutter/ui/tickets/ticket_purchase_dialog.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  final Event? event;
  EventPage(this.event);

  @override
  _EventPageState createState() => _EventPageState(event);
}

class _EventPageState extends State<EventPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  final Event? event;
  _EventPageState(this.event);

  final GlobalKey<State> _loadingDialogKey = new GlobalKey<State>();
  bool _isLoadingVisible = false;
  late FavouritesEventsCubit favouritesEventsCubit;

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> _sendAnalyticsEvent() async {
    analytics.logEvent(name: "event_view", parameters: <String, dynamic>{
      "event_id": event!.eventID,
      "event_name": event!.title,
      "club_id": event!.clubID,
      "club_name": event!.clubName,
    });
  }

  void _initScrollController() {
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
  void initState() {
    super.initState();
    favouritesEventsCubit = BlocProvider.of<FavouritesEventsCubit>(context);
    _initScrollController();
    _sendAnalyticsEvent();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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

  _openClubPage(Club? club) async {
    await _hideLoadingDialog();
    Navigator.pushNamed(context, '/club', arguments: club);
  }

  Future<void> _showLoadingDialog(BuildContext context, String text) async {
    _isLoadingVisible = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(_loadingDialogKey, text);
      },
    );
  }

  Future<void> _hideLoadingDialog() async {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      await Future.delayed(Duration(seconds: 1));
    }

    Navigator.of(_loadingDialogKey.currentContext!, rootNavigator: true).pop();
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
              children: [
                Text(desc, style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: [
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

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : alertUtil.sendAlert(
          BASIC_ERROR_TITLE, CANNOT_LAUNCH_URL_PROMPT, Colors.red, Icons.error);

  void _eventsBlocListener(BuildContext context, state) {
    if (state is ClubLoadedState) {
      Club? club = state.club;

      _openClubPage(club);
    }

    if (state is ClubsErrorState) {
      _showAlertDialog("Something Went Wrong",
          "An error occured. Please check your connection and try again.");
    }
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
          body: BlocListener<EventClubCubit, ClubsState>(
            listener: _eventsBlocListener,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                _appBar(),
                _mainContainer(),
              ],
            ),
          ),
        ),
        _scrollToTopButton(),
      ],
    );
  }

  Widget _mainContainer() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Text(
                event!.title!,
                style: TextStyle(
                    color: Colors.white, fontSize: 28, fontFamily: 'LatoBold'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                event!.clubName!,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 21,
                    fontFamily: 'Lato'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                DateFormat("MMM dd, yyyy · HH:mm")
                    .format(event!.eventStartDate),
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: 'Lato'),
              ),
            ),
            Visibility(
              visible: event!.isAdultOnly!,
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "18+ Only",
                  style: TextStyle(
                      color: Colors.red, fontSize: 18, fontFamily: 'Lato'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(FontAwesomeIcons.globeAfrica, event!.webLink),
                  _socialButton(
                      FontAwesomeIcons.facebookF, event!.facebookLink),
                  _socialButton(FontAwesomeIcons.twitter, event!.twitterLink),
                  _socialButton(
                      FontAwesomeIcons.instagram, event!.instagramLink),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 84),
              child: Text(
                event!.description!,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: 'LatoLight'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String? link) {
    return Visibility(
      visible: link != null,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: RawMaterialButton(
          onPressed: () => _launchURL(link!),
          constraints: BoxConstraints.expand(width: 64, height: 64),
          elevation: 0,
          child: Center(
              child: Icon(
            icon,
            color: Colors.white,
            size: 24.0,
          )),
          padding: EdgeInsets.all(16.0),
          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _scrollToTopButton() {
    return AnimatedOpacity(
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
        ),
      ),
    );
  }

  Widget _appBar() {
    return BlocBuilder<FavouritesEventsCubit, EventsState>(
        builder: (context, favouriteEventsState) {
      bool eventIsFav = favouritesEventsCubit.checkEventExists(event!.eventID);

      return SliverPersistentHeader(
        delegate: EventCollapsingAppBar(
          expandedHeight: 496,
          statusBarHeight: MediaQuery.of(context).padding.top,
          imageUrl: event!.imageUrl,
          showClubButton: event!.clubID != null,
          showTicketButton: event!.hasTickets!,
          onTicketButtonClick: _showTicketPurchasePage(),
          onClubButtonClick: () {
            _showLoadingDialog(context, "Loading Club...");
            final EventClubCubit eventPageClubCubit =
                BlocProvider.of<EventClubCubit>(context);

            eventPageClubCubit.getClub(event!.clubID);
          },
          isEventLiked: eventIsFav,
          onFavButtonClick: () {
            if (favouritesEventsCubit.checkEventExists(event!.eventID)) {
              favouritesEventsCubit.removeFavouriteEvent(event!);
            } else
              favouritesEventsCubit.addFavouriteEvent(event!);
          },
        ),
        floating: false,
        pinned: true,
      );
    });
  }
}
