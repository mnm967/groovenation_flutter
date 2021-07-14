import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClubsHomePage extends StatefulWidget {
  final _ClubsHomePageState state = _ClubsHomePageState();

  void runBuild() {
    state.runBuild();
  }

  @override
  _ClubsHomePageState createState() {
    return state;
  }
}

class _ClubsHomePageState extends State<ClubsHomePage> {
  bool _isFirstView = true;

  runBuild() {
    if (_isFirstView) {
      print("Running Build: ClubsHome");
      _isFirstView = false;

      final FavouritesClubsCubit favouriteClubsCubit =
          BlocProvider.of<FavouritesClubsCubit>(context);

      favouriteClubsCubit.getClubs(0);

      // if (!(favouriteClubsCubit.state is ClubsLoadedState))
      //   favouriteClubsCubit.getClubs(0);
      // else {
      //   print("Loading Nearby...");
      //   _nearbyRefreshController.requestRefresh();

      //   final NearbyClubsCubit nearbyClubsCubit =
      //       BlocProvider.of<NearbyClubsCubit>(context);
      //   nearbyClubsCubit.getClubs(0);

      //   final TopClubsCubit topClubsCubit =
      //       BlocProvider.of<TopClubsCubit>(context);
      //   topClubsCubit.getClubs(0);
      // }
    }
  }

  final _nearbyRefreshController = RefreshController(initialRefresh: true);
  final _topRatedRefreshController = RefreshController(initialRefresh: true);
  final _favouritesRefreshController = RefreshController(initialRefresh: false);

  final ScrollController _nearbyScrollController = new ScrollController();
  final ScrollController _topRatedScrollController = new ScrollController();

  void setListScrollListener(
      ScrollController controller, RefreshController refreshController) {
    controller.addListener(() {
      if (controller.position.pixels >=
          (controller.position.maxScrollExtent - 456)) {
        if (refreshController.footerStatus == LoadStatus.idle) {
          refreshController.requestLoading(needMove: false);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setListScrollListener(_nearbyScrollController, _nearbyRefreshController);
    setListScrollListener(
        _topRatedScrollController, _topRatedRefreshController);
  }

  @override
  void dispose() {
    _nearbyScrollController.dispose();
    _topRatedScrollController.dispose();

    _nearbyRefreshController.dispose();
    _topRatedRefreshController.dispose();
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
              icon: Icon(Icons.local_bar),
              text: "Nearby",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.thumbsUp),
              text: "Top Rated",
            ),
            Tab(
              icon: Icon(Icons.star),
              text: "Favourites",
            ),
          ],
        )
      ]);

  bool _isInitialFavouriteLoad = true;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavouritesClubsCubit, ClubsState>(
        listener: (context, favouriteClubsState) {
      if (favouriteClubsState is ClubsLoadedState && _isFirstView == false) {
        final NearbyClubsCubit nearbyClubsCubit =
            BlocProvider.of<NearbyClubsCubit>(context);

        final TopClubsCubit topClubsCubit =
            BlocProvider.of<TopClubsCubit>(context);

        if (_isInitialFavouriteLoad) {
          _isInitialFavouriteLoad = false;
          nearbyClubsCubit.getClubs(nearbyPage);
          topClubsCubit.getClubs(topRatedPage);
        }
      }
    }, builder: (context, favouriteClubsState) {
      if (favouriteClubsState is ClubsLoadedState) {
        favouriteClubs = favouriteClubsState.clubs;
      }

      return SafeArea(
          child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  topAppBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        nearbyList(),
                        topRatedList(),
                        SmartRefresher(
                          controller: _favouritesRefreshController,
                          header: WaterDropMaterialHeader(),
                          enablePullUp: false,
                          enablePullDown: false,
                          child: favouritesList(),
                        ),
                      ],
                    ),
                  )
                ],
              )));
    });
  }

  Function _getBlocListener(
      RefreshController refreshController, ScrollController scrollController) {
    return (context, state) {
      if (state is ClubsLoadedState) {
        if (refreshController.isRefresh) {
          scrollController.jumpTo(0.0);
          refreshController.refreshCompleted();
          refreshController.loadComplete();
        } else if (refreshController.isLoading) {
          if (state.hasReachedMax)
            refreshController.loadNoData();
          else
            refreshController.loadComplete();
        }
      }
    };
  }

  ClassicFooter _classicFooter = ClassicFooter(
    textStyle: TextStyle(
        color: Colors.white.withOpacity(0.5), fontSize: 16, fontFamily: 'Lato'),
    noDataText: "You've reached the end of the line",
    failedText: "Something Went Wrong",
  );

  List<Club> nearbyClubs = [];
  int nearbyPage = 0;

  Widget nearbyList() {
    return BlocConsumer<NearbyClubsCubit, ClubsState>(
        listener:
            _getBlocListener(_nearbyRefreshController, _nearbyScrollController),
        builder: (context, nearbyClubsState) {
          if (nearbyClubsState is ClubsLoadedState)
            nearbyClubs = nearbyClubsState.clubs;

          if (nearbyClubsState is ClubsErrorState) {
            _nearbyRefreshController.refreshFailed();

            switch (nearbyClubsState.error) {
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

          final FavouritesClubsCubit favouritesClubsCubit =
              BlocProvider.of<FavouritesClubsCubit>(context);

          return SmartRefresher(
              controller: _nearbyRefreshController,
              header: WaterDropMaterialHeader(),
              footer: _classicFooter,
              onRefresh: () {
                if (!checkFavouritesSuccess()) return;

                final NearbyClubsCubit nearbyClubsCubit =
                    BlocProvider.of<NearbyClubsCubit>(context);

                if ((nearbyClubsCubit.state is ClubsLoadedState ||
                        nearbyClubsCubit.state is ClubsErrorState) &&
                    !_isFirstView) {
                  setState(() {
                    nearbyPage = 0;
                  });
                  nearbyClubsCubit.getClubs(nearbyPage);
                }
              },
              onLoading: () {
                if (nearbyClubs.length == 0) {
                  _nearbyRefreshController.loadComplete();
                  return;
                }

                final NearbyClubsCubit nearbyClubsCubit =
                    BlocProvider.of<NearbyClubsCubit>(context);

                setState(() {
                  nearbyPage++;
                });
                nearbyClubsCubit.getClubs(nearbyPage);
              },
              enablePullUp: true,
              child: ListView.builder(
                  padding:
                      EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _nearbyScrollController,
                  itemCount: nearbyClubs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: clubItem(
                            context,
                            nearbyClubs[index],
                            favouritesClubsCubit
                                .checkClubExists(nearbyClubs[index].clubID),
                            index));
                  }));
        });
  }

  List<Club> topClubs = [];
  int topRatedPage = 0;
  bool _isTopFirstInit = true;

  Widget topRatedList() {
    return BlocConsumer<TopClubsCubit, ClubsState>(
        listener: _getBlocListener(
            _topRatedRefreshController, _topRatedScrollController),
        builder: (context, topClubsState) {
          if (topClubsState is ClubsLoadedState) topClubs = topClubsState.clubs;

          if (topClubsState is ClubsErrorState) {
            _topRatedRefreshController.refreshFailed();

            switch (topClubsState.error) {
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

          final FavouritesClubsCubit favouritesClubsCubit =
              BlocProvider.of<FavouritesClubsCubit>(context);

          return SmartRefresher(
              controller: _topRatedRefreshController,
              header: WaterDropMaterialHeader(),
              footer: _classicFooter,
              onRefresh: () {
                if (_isTopFirstInit) {
                  _isTopFirstInit = false;
                  if (!(topClubsState is ClubsLoadingState) &&
                      !(favouritesClubsCubit.state is ClubsLoadingState)) {
                    _topRatedRefreshController.refreshCompleted();
                  }
                  return;
                }

                if (!checkFavouritesSuccess()) return;

                final TopClubsCubit topClubsCubit =
                    BlocProvider.of<TopClubsCubit>(context);

                if ((topClubsCubit.state is ClubsLoadedState ||
                        topClubsCubit.state is ClubsErrorState) &&
                    !_isFirstView) {
                  topRatedPage = 0;
                  topClubsCubit.getClubs(topRatedPage);
                }
              },
              onLoading: () {
                if (topClubs.length == 0) return;

                final TopClubsCubit topClubsCubit =
                    BlocProvider.of<TopClubsCubit>(context);
                topClubsCubit.getClubs(topRatedPage);
              },
              enablePullUp: true,
              child: ListView.builder(
                  padding:
                      EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _topRatedScrollController,
                  itemCount: topClubs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: clubItem(
                            context,
                            topClubs[index],
                            favouritesClubsCubit
                                .checkClubExists(topClubs[index].clubID),
                            index));
                  }));
        });
  }

  bool checkFavouritesSuccess() {
    final FavouritesClubsCubit favouritesClubsCubit =
        BlocProvider.of<FavouritesClubsCubit>(context);
    if (favouritesClubsCubit.state is ClubsErrorState) {
      favouritesClubsCubit.getClubs(0);
      return false;
    }
    if (favouritesClubsCubit.state is ClubsLoadingState) {
      return false;
    }
    return true;
  }

  List<Club> favouriteClubs = [];

  Widget favouritesList() {
    return ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        itemCount: favouriteClubs.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: clubItem(context, favouriteClubs[index], true, index));
        });
  }

  double _getDistanceToClub() {}

  Widget clubItem(
      BuildContext context, Club club, bool isFavourite, int index) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, '/club', arguments: club);
          },
          padding: EdgeInsets.zero,
          child: Wrap(children: [
            Column(
              children: [
                Row(mainAxisSize: MainAxisSize.max, children: [
                  Expanded(
                    child: Container(
                      height: 236,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: OptimizedCacheImageProvider(club.images[0]),
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
                                    final FavouritesClubsCubit
                                        favouritesClubsCubit =
                                        BlocProvider.of<FavouritesClubsCubit>(
                                            context);
                                    if (isFavourite) {
                                      favouritesClubsCubit.removeClub(club);
                                    } else
                                      favouritesClubsCubit.addClub(club);
                                  },
                                  child: Icon(
                                    isFavourite
                                        ? Icons.star
                                        : Icons.star_border,
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
                              height: 84,
                              width: 84,
                              child: CircularPercentIndicator(
                                radius: 79,
                                circularStrokeCap: CircularStrokeCap.round,
                                lineWidth: 5.0,
                                percent: club.averageRating / 5.0,
                                center: new Text(
                                    club.averageRating
                                        .toDouble()
                                        .toStringAsFixed(1),
                                    style: TextStyle(
                                        fontFamily: 'LatoBold',
                                        color: Colors.white,
                                        fontSize: 24)),
                                progressColor: Colors.white,
                                backgroundColor: Colors.black.withOpacity(0.2),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 20, top: 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    club.name,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'LatoBold',
                                        fontSize: 22,
                                        color: Colors.white),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        locationUtil.userLocationStatus ==
                                                UserLocationStatus.FOUND
                                            ? _getDistanceToClub()
                                                    .toStringAsFixed(1) +
                                                " km away"
                                            : "Johannesburg",
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
