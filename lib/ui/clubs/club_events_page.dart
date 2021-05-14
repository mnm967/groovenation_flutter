import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClubEventsPage extends StatefulWidget {
  final Club club;
  ClubEventsPage(this.club);

  @override
  _ClubEventsPageState createState() => _ClubEventsPageState(club);
}

class _ClubEventsPageState extends State<ClubEventsPage> {
  final Club club;
  _ClubEventsPageState(this.club);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  final _eventRefreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollController.addListener(() {
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
            }));
    final ClubEventsCubit clubEventsCubit =
        BlocProvider.of<ClubEventsCubit>(context);
    clubEventsCubit.getEvents(_page, club.clubID);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Event> clubEvents = [];
  bool hasReachedMax = false;
  int _page = 0;

  _onRefresh() {
    _page = 0;

    final ClubEventsCubit clubEventsCubit =
        BlocProvider.of<ClubEventsCubit>(context);
    if (!(clubEventsCubit.state is EventsLoadingState)) {
      clubEventsCubit.getEvents(0, club.clubID);
    }
  }

  _onLoading() {
    if (clubEvents.length == 0 || hasReachedMax) {
      _eventRefreshController.loadNoData();
      return;
    }

    _page++;
    final ClubEventsCubit clubEventsCubit =
        BlocProvider.of<ClubEventsCubit>(context);
    if (!(clubEventsCubit.state is EventsLoadingState)) {
      clubEventsCubit.getEvents(_page, club.clubID);
    }
  }

  ClassicFooter _classicFooter = ClassicFooter(
    textStyle: TextStyle(
        color: Colors.white.withOpacity(0.5), fontSize: 16, fontFamily: 'Lato'),
    noDataText: "You've reached the end of the line",
    failedText: "Something Went Wrong",
  );

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
        child: Stack(children: [
      // CustomScrollView(
      //   controller: _scrollController,
      //   physics: const BouncingScrollPhysics(
      //       parent: AlwaysScrollableScrollPhysics()),
      //   slivers: [
      //     SliverToBoxAdapter(
      //child:
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
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
                          padding: EdgeInsets.only(left: 24, top: 12),
                          child: Text(
                            "Upcoming Events",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontFamily: 'LatoBold'),
                          )),
                    ],
                  )),
              Expanded(
                  child: SmartRefresher(
                      controller: _eventRefreshController,
                      header: WaterDropMaterialHeader(),
                      footer: _classicFooter,
                      onLoading: () => _onLoading(),
                      onRefresh: () => _onRefresh(),
                      enablePullDown: true,
                      enablePullUp: true,
                      child: BlocBuilder<FavouritesEventsCubit, EventsState>(
                          builder: (context, state) =>
                              BlocConsumer<ClubEventsCubit, EventsState>(
                                  listener: (context, state) {
                                if (state is EventsLoadedState) {
                                  _eventRefreshController.refreshCompleted();

                                  if (state.hasReachedMax)
                                    _eventRefreshController.loadNoData();
                                }
                                if (state is EventsErrorState) {
                                  _eventRefreshController.refreshFailed();
                                  switch (state.error) {
                                    case Error.NETWORK_ERROR:
                                      alertUtil.sendAlert(
                                          BASIC_ERROR_TITLE,
                                          NETWORK_ERROR_PROMPT,
                                          Colors.red,
                                          Icons.error);
                                      break;
                                    default:
                                      alertUtil.sendAlert(
                                          BASIC_ERROR_TITLE,
                                          UNKNOWN_ERROR_PROMPT,
                                          Colors.red,
                                          Icons.error);
                                      break;
                                  }
                                }
                              }, builder: (context, state) {
                                if (state is EventsLoadingState) {
                                  return Padding(
                                      padding: EdgeInsets.only(top: 64),
                                      child: Center(
                                          child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2.0,
                                        ),
                                      )));
                                }

                                if (state is EventsLoadedState) {
                                  clubEvents = state.events;
                                  hasReachedMax = state.hasReachedMax;
                                }

                                final FavouritesEventsCubit
                                    favouritesEventsCubit =
                                    BlocProvider.of<FavouritesEventsCubit>(
                                        context);

                                return ListView.builder(
                                    padding:
                                        EdgeInsets.only(top: 12, bottom: 12),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: clubEvents.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              12, 16, 12, 0),
                                          child: Align(
                                            child: eventItem(
                                                context,
                                                clubEvents[index],
                                                favouritesEventsCubit
                                                    .checkEventExists(
                                                        clubEvents[index]
                                                            .eventID),
                                                index),
                                            alignment: Alignment.topCenter,
                                          ));
                                    });
                              }))))
            ],
          )),
      //     )
      //   ],
      // ),
      AnimatedOpacity(
          opacity: _scrollToTopVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 250),
          child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 24, right: 24),
                  child: Card(
                    elevation: 6,
                    color: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple,
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
                          color: Colors.white.withOpacity(0.8),
                          size: 36,
                        ),
                      ),
                    ),
                  ))))
    ]));
  }

  Widget eventItem(
      BuildContext context, Event event, bool isFavourite, int index) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, '/event', arguments: event);
          },
          padding: EdgeInsets.zero,
          child: Wrap(children: [
            Column(
              children: [
                Row(mainAxisSize: MainAxisSize.max, children: [
                  Expanded(
                    child: Container(
                      height: 256,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: OptimizedCacheImageProvider(event.imageUrl),
                            fit: BoxFit.cover),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                            padding: EdgeInsets.only(top: 16, right: 16),
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(9)),
                              child: FlatButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    final FavouritesEventsCubit
                                        favouritesEventsCubit =
                                        BlocProvider.of<FavouritesEventsCubit>(
                                            context);
                                    if (isFavourite) {
                                      favouritesEventsCubit.removeEvent(event);
                                    } else
                                      favouritesEventsCubit.addEvent(event);
                                  },
                                  child: Icon(
                                    isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 28,
                                  )),
                            )),
                      ),
                    ),
                  ),
                ]),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                                height: 76,
                                width: 76,
                                child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      child: Center(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat.MMM()
                                                .format(event.eventStartDate),
                                            style: TextStyle(
                                              fontFamily: 'LatoBold',
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            DateFormat.d()
                                                .format(event.eventStartDate),
                                            style: TextStyle(
                                              fontFamily: 'LatoBold',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )),
                                    ))),
                            Container(
                              padding: EdgeInsets.only(left: 20, top: 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'LatoBold',
                                        fontSize: 22,
                                        color: Colors.white),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        event.clubName,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 18,
                                            color:
                                                Colors.white.withOpacity(0.4)),
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
}
