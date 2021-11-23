import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/event/events_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_events_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_users_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/club_item.dart';
import 'package:groovenation_flutter/ui/events/widgets/event_item.dart';
import 'package:groovenation_flutter/ui/search/widgets/profile_item.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  bool _scrollToTopVisible = false;

  ScrollController _eventScrollController = new ScrollController();
  RefreshController _eventsRefreshController =
      RefreshController(initialRefresh: false);
  final searchTextController = TextEditingController();
  TabController? _tabController;

  ScrollController _clubScrollController = new ScrollController();
  RefreshController _clubsRefreshController =
      RefreshController(initialRefresh: false);

  ScrollController _profileScrollController = new ScrollController();
  RefreshController _profileRefreshController =
      RefreshController(initialRefresh: false);

  void _initScrollController(ScrollController controller) {
    controller.addListener(() {
      if (controller.position.pixels <= 30) {
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

  void _initTabController() {
    _tabController = TabController(vsync: this, length: 3);

    _tabController!.addListener(() {
      if (searchTextController.text.isEmpty) return;

      searchEvents = [];
      searchClubs = [];
      searchUsers = [];
      searchTextController.text = "";
    });
  }

  @override
  void initState() {
    super.initState();
    BlocUtil.clearSearchCubits(context);
    _initTabController();
    _initScrollController(_eventScrollController);
    _initScrollController(_clubScrollController);
    _initScrollController(_profileScrollController);
  }

  @override
  void dispose() {
    super.dispose();
    _eventScrollController.dispose();
    _clubScrollController.dispose();
    _profileScrollController.dispose();
    _tabController!.dispose();
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
                _topAppBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _eventList(),
                      _clubList(),
                      _profileList(),
                    ],
                  ),
                )
              ],
            ),
            _scrollToTopButton(),
          ],
        ),
      ),
    );
  }

  Widget _topAppBar() {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white.withOpacity(0.2)),
          child: _searchTextField(),
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
          Tab(
            icon: Icon(FontAwesomeIcons.users),
            text: "People",
          ),
        ],
      )
    ]);
  }

  InputDecoration _searchInputDecoration() {
    return InputDecoration(
      hintMaxLines: 3,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintText: "Search...",
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(
          Icons.search,
          color: Colors.white,
          size: 28,
        ),
      ),
      prefixIcon: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        padding: EdgeInsets.only(left: 16, right: 24),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _searchTextField() {
    return TextField(
      controller: searchTextController,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.multiline,
      cursorColor: Colors.white.withOpacity(0.7),
      onChanged: (text) {
        if (text.isNotEmpty) {
          if (_tabController!.index == 0) {
            final SearchEventsCubit searchEventsCubit =
                BlocProvider.of<SearchEventsCubit>(context);

            eventsPage = 0;
            // searchEvents = [];

            searchEventsCubit.searchEvents(0, searchTextController.text);
          } else if (_tabController!.index == 1) {
            final SearchClubsCubit searchClubsCubit =
                BlocProvider.of<SearchClubsCubit>(context);

            clubsPage = 0;
            // searchClubs = [];

            searchClubsCubit.searchClubs(0, searchTextController.text);
          } else {
            final SearchUsersCubit searchUsersCubit =
                BlocProvider.of<SearchUsersCubit>(context);

            profilePage = 0;
            // searchUsers = [];

            searchUsersCubit.searchUsers(0, searchTextController.text);
          }
        }
      },
      style: TextStyle(fontFamily: 'Lato', color: Colors.white, fontSize: 20),
      decoration: _searchInputDecoration(),
    );
  }

  Widget _circularProgress() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Center(
        child: SizedBox(
          height: 56,
          width: 56,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  //Events:

  int eventsPage = 0;
  List<Event>? searchEvents = [];

  void _refreshEvents() {
    if (searchTextController.text.isEmpty) {
      _eventsRefreshController.refreshCompleted();

      eventsPage = 0;
      searchEvents = [];
      return;
    }

    final SearchEventsCubit searchEventsCubit =
        BlocProvider.of<SearchEventsCubit>(context);
    eventsPage = 0;
    searchEvents = [];

    searchEventsCubit.searchEvents(0, searchTextController.text);
  }

  void _loadMoreEvents() {
    if (searchEvents!.length == 0) {
      _eventsRefreshController.loadComplete();
      return;
    }

    final SearchEventsCubit searchEventsCubit =
        BlocProvider.of<SearchEventsCubit>(context);

    searchEventsCubit.searchEvents(eventsPage + 1, searchTextController.text);
    eventsPage++;
  }

  void _eventsBlocListener(context, state) {
    if (state is EventsLoadedState) {
      if (_eventsRefreshController.isRefresh) {
        if (_eventScrollController.hasClients)
          _eventScrollController.jumpTo(0.0);
        _eventsRefreshController.refreshCompleted();

        _eventsRefreshController = RefreshController(initialRefresh: false);
      } else if (_eventsRefreshController.isLoading) {
        if (state.hasReachedMax!)
          _eventsRefreshController.loadNoData();
        else
          _eventsRefreshController.loadComplete();
      }
    }
  }

  Widget _eventList() {
    return BlocConsumer<SearchEventsCubit, EventsState>(
      listener: _eventsBlocListener,
      builder: (context, searchEventsState) {
        if (searchEventsState is EventsLoadedState)
          searchEvents = searchEventsState.events;

        if (searchEventsState is EventsErrorState &&
            searchEventsState.error != AppError.REQUEST_CANCELLED)
          return Container(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Text(
              "Something Went Wrong. Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
            ),
          );

        final FavouritesEventsCubit favouritesEventsCubit =
            BlocProvider.of<FavouritesEventsCubit>(context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (searchEventsState is EventsLoadingState && eventsPage == 0)
                ? _circularProgress()
                : Container(),
            Expanded(
                child: SmartRefresher(
              controller: _eventsRefreshController,
              header: CustomMaterialClassicHeader(),
              footer: ClassicFooter(
                textStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'Lato'),
                noDataText: "You've reached the end of the line",
                failedText: "Something Went Wrong",
              ),
              onRefresh: _refreshEvents,
              onLoading: _loadMoreEvents,
              enablePullUp: true,
              child: ListView.builder(
                controller: _eventScrollController,
                padding:
                    EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: searchEvents!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _buildEventItem(index, favouritesEventsCubit),
                  );
                },
              ),
            ))
          ],
        );
      },
    );
  }

  Widget _buildEventItem(index, favouritesEventsCubit) {
    return BlocBuilder<FavouritesEventsCubit, EventsState>(
      builder: (context, _favouriteEventsState) {
        return EventItem(
          event: searchEvents![index],
          isFavourite: favouritesEventsCubit
              .checkEventExists(searchEvents![index].eventID),
        );
      },
    );
  }

  //Users:

  int profilePage = 0;
  List<SocialPerson>? searchUsers = [];

  void _refreshUsers() {
    if (searchTextController.text.isEmpty) {
      _profileRefreshController.refreshCompleted();

      profilePage = 0;
      searchUsers = [];
      return;
    }

    final SearchUsersCubit searchUsersCubit =
        BlocProvider.of<SearchUsersCubit>(context);

    profilePage = 0;
    searchUsers = [];

    searchUsersCubit.searchUsers(0, searchTextController.text);
  }

  void _loadMoreUsers() {
    if (searchUsers!.length == 0) {
      _profileRefreshController.loadComplete();
      return;
    }

    final SearchUsersCubit searchUsersCubit =
        BlocProvider.of<SearchUsersCubit>(context);

    searchUsersCubit.searchUsers(profilePage + 1, searchTextController.text);
    profilePage++;
  }

  void _onSocialUserSelected(SocialPerson person) {
    Navigator.pushNamed(context, '/profile_page', arguments: person);
  }

  void _usersBlocListener(context, state) {
    if (state is SocialUsersSearchLoadedState) {
      if (_profileRefreshController.isRefresh) {
        if (_profileScrollController.hasClients)
          _profileScrollController.jumpTo(0.0);
        _profileRefreshController.refreshCompleted();

        _profileRefreshController = RefreshController(initialRefresh: false);
      } else if (_profileRefreshController.isLoading) {
        if (state.hasReachedMax!)
          _profileRefreshController.loadNoData();
        else
          _profileRefreshController.loadComplete();
      }
    }
  }

  Widget _profileList() {
    return BlocConsumer<SearchUsersCubit, UserState>(
      listener: _usersBlocListener,
      builder: (context, searchUsersState) {
        if (searchUsersState is SocialUsersSearchLoadedState)
          searchUsers = searchUsersState.socialPeople;

        if (searchUsersState is SocialUsersSearchErrorState &&
            searchUsersState.error != AppError.REQUEST_CANCELLED)
          return Container(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Text(
              "Something Went Wrong. Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
            ),
          );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (searchUsersState is SocialUsersSearchLoadingState &&
                    profilePage == 0)
                ? _circularProgress()
                : Container(),
            Expanded(
              child: SmartRefresher(
                controller: _profileRefreshController,
                header: CustomMaterialClassicHeader(),
                footer: ClassicFooter(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato'),
                  noDataText: "You've reached the end of the line",
                  failedText: "Something Went Wrong",
                ),
                onRefresh: _refreshUsers,
                onLoading: _loadMoreUsers,
                enablePullUp: true,
                child: ListView.builder(
                  controller: _profileScrollController,
                  padding:
                      EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: searchUsers!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: ProfileItem(
                        person: searchUsers![index],
                        onUserSelected: (socialPerson) =>
                            _onSocialUserSelected(socialPerson),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //Clubs:

  int clubsPage = 0;
  List<Club?>? searchClubs = [];

  void _refreshClubs() {
    if (searchTextController.text.isEmpty) {
      _clubsRefreshController.refreshCompleted();

      clubsPage = 0;
      searchClubs = [];

      return;
    }

    final SearchClubsCubit searchClubsCubit =
        BlocProvider.of<SearchClubsCubit>(context);

    clubsPage = 0;
    searchClubs = [];

    searchClubsCubit.searchClubs(0, searchTextController.text);
  }

  void _loadMoreClubs() {
    if (searchClubs!.length == 0) {
      _clubsRefreshController.loadComplete();
      return;
    }

    final SearchClubsCubit searchClubsCubit =
        BlocProvider.of<SearchClubsCubit>(context);

    searchClubsCubit.searchClubs(clubsPage + 1, searchTextController.text);
    clubsPage++;
  }

  void _clubBlocListener(context, state) {
    if (state is ClubsLoadedState) {
      if (_clubsRefreshController.isRefresh) {
        if (_clubScrollController.hasClients) _clubScrollController.jumpTo(0.0);
        _clubsRefreshController.refreshCompleted();

        _clubsRefreshController = RefreshController(initialRefresh: false);
      } else if (_clubsRefreshController.isLoading) {
        if (state.hasReachedMax!)
          _clubsRefreshController.loadNoData();
        else
          _clubsRefreshController.loadComplete();
      }
    }
  }

  Widget _clubList() {
    return BlocConsumer<SearchClubsCubit, ClubsState>(
      listener: _clubBlocListener,
      builder: (context, searchClubsState) {
        
        if (searchClubsState is ClubsErrorState &&
            searchClubsState.error != AppError.REQUEST_CANCELLED)
          return Container(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Text(
              "Something Went Wrong. Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
            ),
          );

        if (searchClubsState is ClubsLoadedState)
          searchClubs = searchClubsState.clubs;

        final FavouritesClubsCubit favouritesClubsCubit =
            BlocProvider.of<FavouritesClubsCubit>(context);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (searchClubsState is ClubsLoadingState && clubsPage == 0)
                ? _circularProgress()
                : Container(),
            Expanded(
              child: SmartRefresher(
                controller: _clubsRefreshController,
                header: CustomMaterialClassicHeader(),
                footer: ClassicFooter(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato'),
                  noDataText: "You've reached the end of the line",
                  failedText: "Something Went Wrong",
                ),
                onRefresh: _refreshClubs,
                onLoading: _loadMoreClubs,
                enablePullUp: true,
                child: ListView.builder(
                  controller: _clubScrollController,
                  padding:
                      EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: searchClubs!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _buildClubItem(index, favouritesClubsCubit),
                    );
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildClubItem(index, favouritesClubsCubit) {
    return BlocBuilder<FavouritesClubsCubit, ClubsState>(
      builder: (context, _favouriteClubsState) {
        return ClubItem(
          club: searchClubs![index],
          isFavourite:
              favouritesClubsCubit.checkClubExists(searchClubs![index]!.clubID),
        );
      },
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
                color: Colors.deepPurple.withOpacity(0.7),
                borderRadius: BorderRadius.circular(9)),
            child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _eventScrollController.animateTo(
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
        ),
      ),
    );
  }
}
