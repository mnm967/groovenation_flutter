import 'dart:ui';

import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventsHomePage extends StatefulWidget {
  final int page;
  final _EventsHomePageState state = _EventsHomePageState();

  void runBuild() {
    state.runBuild();
  }

  EventsHomePage(this.page);

  @override
  _EventsHomePageState createState() {
    return state;
  }
}

class _EventsHomePageState extends State<EventsHomePage> {
  bool _isFirstView = true;

  runBuild() {
    if (_isFirstView) {
      int pg = widget.page;
      print("Running Build: $pg");
      _isFirstView = false;

      // final FavouritesEventsCubit favouriteEventsCubit =
      //     BlocProvider.of<FavouritesEventsCubit>(context);

      // favouriteEventsCubit.getEvents(0);
    }
  }

  final FlareControls flareControls = FlareControls();
  final ScrollController _upcomingScrollController = new ScrollController();

  RefreshController _upcomingRefreshController =
      RefreshController(initialRefresh: true);
  final _favouritesRefreshController = RefreshController(initialRefresh: false);

  void setListScrollListener(
      ScrollController controller, RefreshController refreshController) {
    controller.addListener(() {
      if (controller.position.pixels >=
          (controller.position.maxScrollExtent - 456)) {
        if (refreshController.footerStatus == LoadStatus.idle) {
          if(mounted) refreshController.requestLoading(needMove: false);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

      final FavouritesEventsCubit favouriteEventsCubit =
        BlocProvider.of<FavouritesEventsCubit>(context);

      favouriteEventsCubit.getEvents(0);

      WidgetsBinding.instance
        .addPostFrameCallback((_) => setListScrollListener(
        _upcomingScrollController, _upcomingRefreshController));
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
              icon: Icon(Icons.whatshot),
              text: "Upcoming",
            ),
            Tab(
              icon: Icon(Icons.favorite),
              text: "Favourites",
            ),
          ],
        )
      ]);

  @override
  void dispose() {
    _upcomingScrollController.dispose();
    _upcomingRefreshController.dispose();

    // _favouritesScrollController.dispose();
    // _favouritesRefreshController.dispose();
    super.dispose();
  }

  bool _isInitialFavouriteLoad = true;

  @override
  Widget build(BuildContext context) {
    int pg = widget.page;
    if (pg == 1 && _isFirstView) runBuild();

    return BlocConsumer<FavouritesEventsCubit, EventsState>(
        listener: (context, favouriteEventsState) {
      if (favouriteEventsState is EventsLoadedState && _isFirstView == false) {
        final UpcomingEventsCubit upcomingEventsCubit =
            BlocProvider.of<UpcomingEventsCubit>(context);
        if (_isInitialFavouriteLoad) {
          _isInitialFavouriteLoad = false;
          upcomingEventsCubit.getEvents(upcomingPage);
        }
      }
    }, builder: (context, favouriteEventsState) {
      if (favouriteEventsState is EventsLoadedState) {
        favouriteEvents = favouriteEventsState.events;
      }

      return SafeArea(
          child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  topAppBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        upcomingList(),
                        SmartRefresher(
                          controller: _favouritesRefreshController,
                          header: WaterDropMaterialHeader(),
                          enablePullDown: false,
                          enablePullUp: false,
                          child: favouritesList(),
                        ),
                      ],
                    ),
                  )
                ],
              )));
    });
  }

  List<Event> upcomingEvents = [];
  int upcomingPage = 0;

  Widget upcomingList() {
    return BlocConsumer<UpcomingEventsCubit, EventsState>(
        listener: (context, state) {
      if (state is EventsLoadedState) {
        // setState(() {
        //         upcomingPage++;
        //       });
        if (_upcomingRefreshController.isRefresh) {
          _upcomingScrollController.jumpTo(0.0);
          _upcomingRefreshController.refreshCompleted();
          _upcomingRefreshController.loadComplete();

          _upcomingRefreshController = RefreshController(initialRefresh: false);
        } else if (_upcomingRefreshController.isLoading) {
          if (state.hasReachedMax)
            _upcomingRefreshController.loadNoData();
          else
            _upcomingRefreshController.loadComplete();
        }
      }
    }, builder: (context, upcomingEventsState) {
      if (upcomingEventsState is EventsLoadedState)
        upcomingEvents = upcomingEventsState.events;

      if (upcomingEventsState is EventsErrorState) {
        switch (upcomingEventsState.error) {
          case Error.NETWORK_ERROR:
            alertUtil.sendAlert(BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT,
                Colors.red, Icons.error);
            break;
          default:
            alertUtil.sendAlert(BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT,
                Colors.red, Icons.error);
            break;
        }
      }

      final FavouritesEventsCubit favouritesEventsCubit =
          BlocProvider.of<FavouritesEventsCubit>(context);

      return SmartRefresher(
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
          onRefresh: () {
            print("favsuc:" + checkFavouritesSuccess().toString());

            if (!checkFavouritesSuccess()) return;

            final UpcomingEventsCubit upcomingEventsCubit =
                BlocProvider.of<UpcomingEventsCubit>(context);

            if ((upcomingEventsCubit.state is EventsLoadedState ||
                    upcomingEventsCubit.state is EventsErrorState) &&
                !_isFirstView) {
              setState(() {
                upcomingPage = 0;
              });

              _upcomingRefreshController.loadComplete();

              upcomingEventsCubit.getEvents(0);
            }
          },
          onLoading: () {
            if (upcomingEvents.length == 0) {
              _upcomingRefreshController.loadComplete();
              return;
            }

            final UpcomingEventsCubit upcomingEventsCubit =
                BlocProvider.of<UpcomingEventsCubit>(context);

            setState(() {
              upcomingPage++;
            });

            upcomingEventsCubit.getEvents(upcomingPage);
          },
          enablePullUp: true,
          child: ListView.builder(
              controller: _upcomingScrollController,
              padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: eventItem(
                        context,
                        upcomingEvents[index],
                        favouritesEventsCubit
                            .checkEventExists(upcomingEvents[index].eventID),
                        index));
              }));
    });
  }

  bool checkFavouritesSuccess() {
    final FavouritesEventsCubit favouritesEventsCubit =
        BlocProvider.of<FavouritesEventsCubit>(context);
    if (favouritesEventsCubit.state is EventsErrorState) {
      favouritesEventsCubit.getEvents(0);
      return false;
    }
    if (favouritesEventsCubit.state is EventsLoadingState) {
      return false;
    }
    return true;
  }

  List<Event> favouriteEvents = [];

  Widget favouritesList() {
    return ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        itemCount: favouriteEvents.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: eventItem(context, favouriteEvents[index], true, index));
        });
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
                            image: CachedNetworkImageProvider(event.imageUrl),
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
