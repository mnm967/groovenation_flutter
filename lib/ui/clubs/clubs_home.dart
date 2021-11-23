import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/club_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:groovenation_flutter/widgets/top_app_bar.dart';
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
  late FavouritesClubsCubit _favouritesClubsCubit;

  final _nearbyRefreshController = RefreshController(initialRefresh: true);
  final _topRatedRefreshController = RefreshController(initialRefresh: true);
  final _favouritesRefreshController = RefreshController(initialRefresh: false);

  final ScrollController _nearbyScrollController = new ScrollController();
  final ScrollController _topRatedScrollController = new ScrollController();

  void runBuild() {
    if (_isFirstView) {
      _isFirstView = false;
      _favouritesClubsCubit.getClubs(0);
    }
  }

  void _setListScrollListener(
      ScrollController controller, RefreshController refreshController) {
    controller.addListener(
      () {
        if (controller.position.pixels >=
            (controller.position.maxScrollExtent - 456)) {
          if (refreshController.footerStatus == LoadStatus.idle) {
            refreshController.requestLoading(needMove: false);
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _favouritesClubsCubit = BlocProvider.of<FavouritesClubsCubit>(context);

    _setListScrollListener(_nearbyScrollController, _nearbyRefreshController);
    _setListScrollListener(
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

  bool _isInitialFavouriteLoad = true;
  final List<Tab> _tabs = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavouritesClubsCubit, ClubsState>(
      listener: _favouritesBlocListener,
      builder: (context, _favouriteClubsState) {
        if (_favouriteClubsState is ClubsLoadedState) {
          _favouriteClubs = _favouriteClubsState.clubs;
        }

        return SafeArea(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TopAppBar(
                  tabs: _tabs,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _nearbyList(),
                      _topRatedList(),
                      _favouritesList(),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _favouritesBlocListener(context, _favouriteClubsState) {
    if (_favouriteClubsState is ClubsLoadedState && _isFirstView == false) {
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
          if (state.hasReachedMax!)
            refreshController.loadNoData();
          else
            refreshController.loadComplete();
        }
      }
    };
  }

  void _checkClubError(ClubsState state, RefreshController refreshController) {
    if (state is ClubsErrorState) {
      refreshController.refreshFailed();

      switch (state.error) {
        case AppError.NETWORK_ERROR:
          alertUtil.sendAlert(
              BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
          break;
        default:
          alertUtil.sendAlert(
              BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
          break;
      }
    }
  }

  ClassicFooter _classicFooter = ClassicFooter(
    textStyle: TextStyle(
        color: Colors.white.withOpacity(0.5), fontSize: 16, fontFamily: 'Lato'),
    noDataText: "You've reached the end of the line",
    failedText: "Something Went Wrong",
  );

  //Nearby Clubs:

  List<Club?>? nearbyClubs = [];
  int nearbyPage = 0;

  void _refreshNearby() {
    if (!_isFavouritesRequestSuccess()) return;

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
  }

  void _loadMoreNearby() {
    if (nearbyClubs!.length == 0) {
      _nearbyRefreshController.loadComplete();
      return;
    }

    final NearbyClubsCubit nearbyClubsCubit =
        BlocProvider.of<NearbyClubsCubit>(context);

    setState(() {
      nearbyPage++;
    });

    nearbyClubsCubit.getClubs(nearbyPage);
  }

  Widget _nearbyList() {
    return BlocConsumer<NearbyClubsCubit, ClubsState>(
      listener:
          _getBlocListener(_nearbyRefreshController, _nearbyScrollController) as void Function(BuildContext, ClubsState),
      builder: (context, nearbyClubsState) {
        if (nearbyClubsState is ClubsLoadedState)
          nearbyClubs = nearbyClubsState.clubs;

        _checkClubError(nearbyClubsState, _nearbyRefreshController);

        return SmartRefresher(
          controller: _nearbyRefreshController,
          header: CustomMaterialClassicHeader(),
          footer: _classicFooter,
          onRefresh: _refreshNearby,
          onLoading: _loadMoreNearby,
          enablePullUp: true,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            controller: _nearbyScrollController,
            itemCount: nearbyClubs!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ClubItem(
                  club: nearbyClubs![index],
                  isFavourite: _favouritesClubsCubit
                      .checkClubExists(nearbyClubs![index]!.clubID),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //Top Rated Clubs:

  List<Club?>? topClubs = [];
  int topRatedPage = 0;
  bool _isTopFirstInit = true;

  void _refreshTopRated(ClubsState topClubsState) {
    if (_isTopFirstInit) {
      _isTopFirstInit = false;
      if (!(topClubsState is ClubsLoadingState) &&
          !(_favouritesClubsCubit.state is ClubsLoadingState)) {
        _topRatedRefreshController.refreshCompleted();
      }
      return;
    }

    if (!_isFavouritesRequestSuccess()) return;

    final TopClubsCubit topClubsCubit = BlocProvider.of<TopClubsCubit>(context);

    if ((topClubsCubit.state is ClubsLoadedState ||
            topClubsCubit.state is ClubsErrorState) &&
        !_isFirstView) {
      topRatedPage = 0;
      topClubsCubit.getClubs(topRatedPage);
    }
  }

  void _loadMoreTopClubs() {
    if (topClubs!.length == 0) return;

    final TopClubsCubit topClubsCubit = BlocProvider.of<TopClubsCubit>(context);
    topClubsCubit.getClubs(topRatedPage);
  }

  Widget _topRatedList() {
    return BlocConsumer<TopClubsCubit, ClubsState>(
      listener: _getBlocListener(
          _topRatedRefreshController, _topRatedScrollController) as void Function(BuildContext, ClubsState),
      builder: (context, topClubsState) {
        if (topClubsState is ClubsLoadedState) topClubs = topClubsState.clubs;

        _checkClubError(topClubsState, _topRatedRefreshController);

        return SmartRefresher(
          controller: _topRatedRefreshController,
          header: CustomMaterialClassicHeader(),
          footer: _classicFooter,
          onRefresh: () => _refreshTopRated(topClubsState),
          onLoading: _loadMoreTopClubs,
          enablePullUp: true,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            controller: _topRatedScrollController,
            itemCount: topClubs!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ClubItem(
                  club: topClubs![index],
                  isFavourite: _favouritesClubsCubit
                      .checkClubExists(topClubs![index]!.clubID),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //Favourite Clubs:
  List<Club?>? _favouriteClubs = [];

  bool _isFavouritesRequestSuccess() {
    if (_favouritesClubsCubit.state is ClubsErrorState) {
      _favouritesClubsCubit.getClubs(0);
      return false;
    }
    if (_favouritesClubsCubit.state is ClubsLoadingState) {
      return false;
    }
    return true;
  }

  Widget _favouritesList() {
    return SmartRefresher(
      controller: _favouritesRefreshController,
      header: CustomMaterialClassicHeader(),
      enablePullUp: false,
      enablePullDown: false,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        itemCount: _favouriteClubs!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ClubItem(club: _favouriteClubs![index], isFavourite: true),
          );
        },
      ),
    );
  }
}
