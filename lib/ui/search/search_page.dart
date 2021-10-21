import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/cubit/user_cubit.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  RefreshController _eventsRefreshController =
      RefreshController(initialRefresh: false);
  final searchTextController = TextEditingController();
  TabController _tabController;

  ScrollController _clubScrollController = new ScrollController();
  RefreshController _clubsRefreshController =
      RefreshController(initialRefresh: false);

  ScrollController _profileScrollController = new ScrollController();
  RefreshController _profileRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      if (searchTextController.text.isEmpty) return;

      if (_tabController.index == 0) {
        final SearchEventsCubit searchEventsCubit =
            BlocProvider.of<SearchEventsCubit>(context);
        setState(() {
          eventsPage = 0;
          searchEvents = [];
        });

        _eventsRefreshController.loadComplete();

        searchEventsCubit.searchEvents(0, searchTextController.text);
      } else if (_tabController.index == 1) {
        final SearchClubsCubit searchClubsCubit =
            BlocProvider.of<SearchClubsCubit>(context);
        setState(() {
          clubsPage = 0;
          searchClubs = [];
        });

        _clubsRefreshController.loadComplete();

        searchClubsCubit.searchClubs(0, searchTextController.text);
      } else {
        final SearchUsersCubit searchUsersCubit =
            BlocProvider.of<SearchUsersCubit>(context);
        setState(() {
          profilePage = 0;
          searchUsers = [];
        });

        _clubsRefreshController.loadComplete();

        searchUsersCubit.searchUsers(0, searchTextController.text);
      }
    });

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

    _profileScrollController.addListener(() {
      if (_profileScrollController.position.pixels <= 30) {
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
    _clubScrollController.dispose();
    _profileScrollController.dispose();
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
                  if (_tabController.index == 0)
                    _eventsRefreshController.requestRefresh();
                  else if (_tabController.index == 1) {
                    final SearchClubsCubit searchClubsCubit =
                        BlocProvider.of<SearchClubsCubit>(context);
                    setState(() {
                      clubsPage = 0;
                      searchClubs = [];
                    });

                    _clubsRefreshController.loadComplete();

                    searchClubsCubit.searchClubs(0, searchTextController.text);
                  } else {
                    final SearchUsersCubit searchUsersCubit =
                        BlocProvider.of<SearchUsersCubit>(context);
                    setState(() {
                      profilePage = 0;
                      searchUsers = [];
                    });

                    _profileRefreshController.loadComplete();

                    searchUsersCubit.searchUsers(0, searchTextController.text);
                  }
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
              icon: Icon(Icons.whatshot),
              text: "Events",
            ),
            Tab(
              icon: Icon(Icons.local_bar),
              text: "Clubs",
            ),
            // Tab(
            //   icon: Icon(FontAwesomeIcons.ticketAlt),
            //   text: "Tickets",
            // ),
            Tab(
              icon: Icon(FontAwesomeIcons.users),
              text: "People",
            ),
          ],
        )
      ]);

  int eventsPage = 0;
  List<Event> searchEvents = [];

  Widget eventList() {
    return BlocConsumer<SearchEventsCubit, EventsState>(
        listener: (context, state) {
      if (state is EventsLoadedState) {
        if (_eventsRefreshController.isRefresh) {
          if(_scrollController.hasClients) _scrollController.jumpTo(0.0);
          _eventsRefreshController.refreshCompleted();
          _eventsRefreshController.loadComplete();

          _eventsRefreshController = RefreshController(initialRefresh: false);
        } else if (_eventsRefreshController.isLoading) {
          if (state.hasReachedMax)
            _eventsRefreshController.loadNoData();
          else
            _eventsRefreshController.loadComplete();
        }
      }
    }, builder: (context, searchEventsState) {
      if (searchEventsState is EventsLoadingState && eventsPage == 0) {
        return Padding(
            padding: EdgeInsets.only(top: 64),
            child: Center(
                child: SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )));
      }

      if (searchEventsState is EventsLoadedState)
        searchEvents = searchEventsState.events;

      if (searchEventsState is EventsErrorState) {
        switch (searchEventsState.error) {
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
          controller: _eventsRefreshController,
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
            if (_tabController.index != 0) {
              final SearchClubsCubit searchClubsCubit =
                  BlocProvider.of<SearchClubsCubit>(context);
              setState(() {
                clubsPage = 0;
                searchClubs = [];
              });

              _clubsRefreshController.loadComplete();

              searchClubsCubit.searchClubs(0, searchTextController.text);
              return;
            }

            final SearchEventsCubit searchEventsCubit =
                BlocProvider.of<SearchEventsCubit>(context);
            setState(() {
              eventsPage = 0;
              searchEvents = [];
            });

            _eventsRefreshController.loadComplete();

            searchEventsCubit.searchEvents(0, searchTextController.text);
          },
          onLoading: () {
            if (searchEvents.length == 0) {
              _eventsRefreshController.loadComplete();
              return;
            }

            final SearchEventsCubit searchEventsCubit =
                BlocProvider.of<SearchEventsCubit>(context);

            setState(() {
              eventsPage++;
            });

            searchEventsCubit.searchEvents(
                eventsPage, searchTextController.text);
          },
          enablePullUp: true,
          child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: searchEvents.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: eventItem(
                        context,
                        searchEvents[index],
                        favouritesEventsCubit
                            .checkEventExists(searchEvents[index].eventID),
                        index));
              }));
    });
  }

  int profilePage = 0;
  List<SocialPerson> searchUsers = [];

  Widget profileList() {
    return BlocConsumer<SearchUsersCubit, UserState>(
        listener: (context, state) {
      if (state is SocialUsersSearchLoadedState) {
        if (_profileRefreshController.isRefresh) {
          if(_profileScrollController.hasClients) _profileScrollController.jumpTo(0.0);
          _profileRefreshController.refreshCompleted();
          _profileRefreshController.loadComplete();

          _profileRefreshController = RefreshController(initialRefresh: false);
        } else if (_profileRefreshController.isLoading) {
          if (state.hasReachedMax)
            _profileRefreshController.loadNoData();
          else
            _profileRefreshController.loadComplete();
        }
      }
    }, builder: (context, searchUsersState) {
      if (searchUsersState is SocialUsersSearchLoadingState && profilePage == 0) {
        return Padding(
            padding: EdgeInsets.only(top: 64),
            child: Center(
                child: SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )));
      }

      if (searchUsersState is SocialUsersSearchLoadedState)
        searchUsers = searchUsersState.socialPeople;

      if (searchUsersState is SocialUsersSearchErrorState) {
        switch (searchUsersState.error) {
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

      return SmartRefresher(
          controller: _profileRefreshController,
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
            final SearchUsersCubit searchUsersCubit =
                BlocProvider.of<SearchUsersCubit>(context);
            setState(() {
              profilePage = 0;
              searchUsers = [];
            });

            _profileRefreshController.loadComplete();

            searchUsersCubit.searchUsers(0, searchTextController.text);
          },
          onLoading: () {
            if (searchUsers.length == 0) {
              _profileRefreshController.loadComplete();
              return;
            }

            final SearchUsersCubit searchUsersCubit =
                BlocProvider.of<SearchUsersCubit>(context);

            setState(() {
              profilePage++;
            });

            searchUsersCubit.searchUsers(
                profilePage, searchTextController.text);
          },
          enablePullUp: true,
          child: ListView.builder(
              controller: _profileScrollController,
              padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: searchUsers.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: profileItem(context, searchUsers[index]));
              }));
    });
  }

  int clubsPage = 0;
  List<Club> searchClubs = [];

  Widget clubList() {
    return BlocConsumer<SearchClubsCubit, ClubsState>(
        listener: (context, state) {
      if (state is ClubsLoadedState) {
        if (_clubsRefreshController.isRefresh) {
          if(_clubScrollController.hasClients) _clubScrollController.jumpTo(0.0);
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

      if (searchClubsState is ClubsLoadingState && clubsPage == 0) {
        return Padding(
            padding: EdgeInsets.only(top: 64),
            child: Center(
                child: SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )));
      }

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
                            image: CachedNetworkImageProvider(club.images[0]),
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

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Stack(
            children: [
              Column(
                children: [
                  topAppBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [eventList(), clubList(), profileList()],
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

                              _clubScrollController.animateTo(
                                0.0,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );

                              _profileScrollController.animateTo(
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

  Widget profileItem(BuildContext context, SocialPerson person) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 4,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile_page',
                    arguments: person);
              },
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
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  person.personProfilePicURL),
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
                                                      person.personUsername,
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
