import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClubSearchPage extends StatefulWidget {
  final Function onClubSelected;

  const ClubSearchPage({Key key, this.onClubSelected}) : super(key: key);

  @override
  _ClubSearchPageState createState() => _ClubSearchPageState(onClubSelected);
}

class _ClubSearchPageState extends State<ClubSearchPage>
    with SingleTickerProviderStateMixin {
  final Function onClubSelected;

  _ClubSearchPageState(this.onClubSelected);

  bool _scrollToTopVisible = false;
  final searchTextController = TextEditingController();
  TabController _tabController;

  ScrollController _clubScrollController = new ScrollController();
  RefreshController _clubsRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 1);
    _tabController.addListener(() {
      if (searchTextController.text.isEmpty) return;

      final SearchClubsCubit searchClubsCubit =
          BlocProvider.of<SearchClubsCubit>(context);
      setState(() {
        clubsPage = 0;
        searchClubs = [];
      });

      _clubsRefreshController.loadComplete();

      searchClubsCubit.searchClubs(0, searchTextController.text);
    });

    _clubScrollController.addListener(() {
      if (_clubScrollController.position.pixels <= 30) {
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
    _clubScrollController.dispose();
    _tabController.dispose();
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
              controller: searchTextController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              autofocus: true,
              cursorColor: Colors.white.withOpacity(0.7),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  final SearchClubsCubit searchClubsCubit =
                      BlocProvider.of<SearchClubsCubit>(context);
                  setState(() {
                    clubsPage = 0;
                    searchClubs = [];
                  });

                  _clubsRefreshController.loadComplete();

                  searchClubsCubit.searchClubs(0, searchTextController.text);
                }
              },
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
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.local_bar),
              text: "Clubs",
            ),
          ],
        )
      ]);

  int clubsPage = 0;
  List<Club> searchClubs = [];

  Widget clubList() {
    return BlocConsumer<SearchClubsCubit, ClubsState>(
        listener: (context, state) {
      if (state is ClubsLoadedState) {
        if (_clubsRefreshController.isRefresh) {
          _clubScrollController.jumpTo(0.0);
          _clubsRefreshController.refreshCompleted();
          _clubsRefreshController.loadComplete();

          _clubsRefreshController = RefreshController(initialRefresh: false);
        } else if (_clubsRefreshController.isLoading) {
          if (state.hasReachedMax)
            _clubsRefreshController.loadNoData();
          else
            _clubsRefreshController.loadComplete();
        }
      }
    }, builder: (context, searchClubsState) {
      if (searchClubsState is ClubsLoadedState)
        searchClubs = searchClubsState.clubs;

      if (searchClubsState is ClubsErrorState) {
        switch (searchClubsState.error) {
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
          controller: _clubsRefreshController,
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
            final SearchClubsCubit searchClubsCubit =
                BlocProvider.of<SearchClubsCubit>(context);
            setState(() {
              clubsPage = 0;
              searchClubs = [];
            });

            _clubsRefreshController.loadComplete();

            searchClubsCubit.searchClubs(0, searchTextController.text);
          },
          onLoading: () {
            if (searchClubs.length == 0) {
              _clubsRefreshController.loadComplete();
              return;
            }

            final SearchClubsCubit searchClubsCubit =
                BlocProvider.of<SearchClubsCubit>(context);

            setState(() {
              clubsPage++;
            });

            searchClubsCubit.searchClubs(clubsPage, searchTextController.text);
          },
          enablePullUp: true,
          child: ListView.builder(
              controller: _clubScrollController,
              padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: searchClubs.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: clubItem(
                        context,
                        searchClubs[index],
                        favouritesClubsCubit
                            .checkClubExists(searchClubs[index].clubID),
                        index));
              }));
    });
  }

  double _getDistanceToClub() {
    return 0.0;
  }

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
            onClubSelected(club.clubID, club.name);
            Navigator.pop(context);
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
                            image: CachedNetworkImageProvider(club.images[0]),
                            fit: BoxFit.cover),
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

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: DefaultTabController(
          length: 1,
          child: Stack(
            children: [
              Column(
                children: [
                  topAppBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        clubList(),
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
                              _clubScrollController.animateTo(
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
}
