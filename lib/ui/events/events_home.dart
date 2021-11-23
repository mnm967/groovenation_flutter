import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/event/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/ui/events/widgets/event_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:groovenation_flutter/widgets/top_app_bar.dart';
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
  final ScrollController _upcomingScrollController = new ScrollController();
  late FavouritesEventsCubit _favouriteEventsCubit;

  RefreshController _upcomingRefreshController =
      RefreshController(initialRefresh: true);
  final _favouritesRefreshController = RefreshController(initialRefresh: false);


  runBuild() {
    if (_isFirstView) {
      int pg = widget.page;
      print("Running Build: $pg");
      _isFirstView = false;
    }
  }



  void _setListScrollListener(ScrollController controller) {
    controller.addListener(() {
      if (controller.position.pixels >=
          (controller.position.maxScrollExtent - 456)) {
        if (_upcomingRefreshController.footerStatus == LoadStatus.idle) {
          _upcomingRefreshController.requestLoading(needMove: false);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _favouriteEventsCubit = BlocProvider.of<FavouritesEventsCubit>(context);
    _favouriteEventsCubit.getEvents(0);

    _setListScrollListener(_upcomingScrollController);
  }

  @override
  void dispose() {
    super.dispose();
    _upcomingScrollController.dispose();
    _upcomingRefreshController.dispose();
  }

  void _checkEventError(EventsState state) {
    if (state is EventsErrorState) {
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

  bool _isInitialFavouriteLoad = true;
  final List<Tab> _tabs = [
    Tab(
      icon: Icon(Icons.whatshot),
      text: "Upcoming",
    ),
    Tab(
      icon: Icon(Icons.favorite),
      text: "Favourites",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int pg = widget.page;
    if (pg == 1 && _isFirstView) runBuild();

    return BlocConsumer<FavouritesEventsCubit, EventsState>(
      listener: _favouritesBlocListener,
      builder: (context, favouriteEventsState) {
        if (favouriteEventsState is EventsLoadedState) {
          favouriteEvents = favouriteEventsState.events;
        }

        return SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TopAppBar(tabs: _tabs),
                Expanded(
                  child: TabBarView(
                    children: [
                      _upcomingList(),
                      _favouritesList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Upcoming Events:

  List<Event>? upcomingEvents = [];
  int upcomingPage = 0;

  void _refreshUpcoming() {
    if (!_isFavouritesRequestSuccess()) return;

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
  }

  void _loadMoreUpcoming() {
    if (upcomingEvents!.length == 0) {
      _upcomingRefreshController.loadComplete();
      return;
    }

    final UpcomingEventsCubit upcomingEventsCubit =
        BlocProvider.of<UpcomingEventsCubit>(context);

    setState(() {
      upcomingPage++;
    });

    upcomingEventsCubit.getEvents(upcomingPage);
  }

  void _upcomingBlocListener(context, state) {
    if (state is EventsLoadedState) {
      if (_upcomingRefreshController.isRefresh) {
        _upcomingScrollController.jumpTo(0.0);
        _upcomingRefreshController.refreshCompleted();
        _upcomingRefreshController.loadComplete();

        _upcomingRefreshController = RefreshController(initialRefresh: false);
      } else if (_upcomingRefreshController.isLoading) {
        if (state.hasReachedMax!)
          _upcomingRefreshController.loadNoData();
        else
          _upcomingRefreshController.loadComplete();
      }
    }
  }

  Widget _upcomingList() {
    return BlocConsumer<UpcomingEventsCubit, EventsState>(
      listener: _upcomingBlocListener,
      builder: (context, upcomingEventsState) {
        if (upcomingEventsState is EventsLoadedState)
          upcomingEvents = upcomingEventsState.events;

        _checkEventError(upcomingEventsState);

        return SmartRefresher(
          controller: _upcomingRefreshController,
          header: CustomMaterialClassicHeader(),
          footer: ClassicFooter(
            textStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontFamily: 'Lato'),
            noDataText: "You've reached the end of the line",
            failedText: "Something Went Wrong",
          ),
          onRefresh: _refreshUpcoming,
          onLoading: _loadMoreUpcoming,
          enablePullUp: true,
          child: ListView.builder(
            controller: _upcomingScrollController,
            padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: upcomingEvents!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: EventItem(
                  event: upcomingEvents![index],
                  isFavourite: _favouriteEventsCubit
                      .checkEventExists(upcomingEvents![index].eventID),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //Favourite Events:

  List<Event>? favouriteEvents = [];

  void _favouritesBlocListener(context, favouriteEventsState) {
    if (favouriteEventsState is EventsLoadedState && _isFirstView == false) {
      final UpcomingEventsCubit upcomingEventsCubit =
          BlocProvider.of<UpcomingEventsCubit>(context);
      if (_isInitialFavouriteLoad) {
        _isInitialFavouriteLoad = false;
        upcomingEventsCubit.getEvents(upcomingPage);
      }
    }
  }

  bool _isFavouritesRequestSuccess() {
    if (_favouriteEventsCubit.state is EventsErrorState) {
      _favouriteEventsCubit.getEvents(0);
      return false;
    }
    if (_favouriteEventsCubit.state is EventsLoadingState) {
      return false;
    }
    return true;
  }

  Widget _favouritesList() {
    return SmartRefresher(
      controller: _favouritesRefreshController,
      header: CustomMaterialClassicHeader(),
      enablePullDown: false,
      enablePullUp: false,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        itemCount: favouriteEvents!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: EventItem(event: favouriteEvents![index], isFavourite: true),
          );
        },
      ),
    );
  }
}
