import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/club/club_events_cubit.dart';
import 'package:groovenation_flutter/cubit/event/events_cubit.dart';
import 'package:groovenation_flutter/cubit/state/events_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/ui/events/widgets/event_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClubEventsPage extends StatefulWidget {
  final Club? club;
  ClubEventsPage(this.club);

  @override
  _ClubEventsPageState createState() => _ClubEventsPageState(club);
}

class _ClubEventsPageState extends State<ClubEventsPage> {
  final Club? club;
  _ClubEventsPageState(this.club);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  final _eventRefreshController = RefreshController(initialRefresh: false);
  List<Event>? clubEvents = [];
  bool? hasReachedMax = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _initScrollController());
    final ClubEventsCubit clubEventsCubit =
        BlocProvider.of<ClubEventsCubit>(context);
    clubEventsCubit.getEvents(_page, club!.clubID!);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  _onRefresh() {
    _page = 0;

    final ClubEventsCubit clubEventsCubit =
        BlocProvider.of<ClubEventsCubit>(context);
    if (!(clubEventsCubit.state is EventsLoadingState)) {
      clubEventsCubit.getEvents(0, club!.clubID!);
    }
  }

  _onLoading() {
    if (clubEvents!.length == 0 || hasReachedMax!) {
      _eventRefreshController.loadNoData();
      return;
    }

    _page++;
    final ClubEventsCubit clubEventsCubit =
        BlocProvider.of<ClubEventsCubit>(context);
    if (!(clubEventsCubit.state is EventsLoadingState)) {
      clubEventsCubit.getEvents(_page, club!.clubID!);
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
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
              children: [
                _header(),
                _smartRefresherList(),
              ],
            ),
          ),
          _scrollToTopButton()
        ],
      ),
    );
  }

  Widget _smartRefresherList() {
    return Expanded(
      child: SmartRefresher(
        controller: _eventRefreshController,
        header: CustomMaterialClassicHeader(),
        footer: _classicFooter,
        onLoading: () => _onLoading(),
        onRefresh: () => _onRefresh(),
        enablePullDown: true,
        enablePullUp: true,
        child: BlocBuilder<FavouritesEventsCubit, EventsState>(
          builder: (context, state) =>
              BlocConsumer<ClubEventsCubit, EventsState>(
            listener: _blocListener,
            builder: (context, state) {
              if (state is EventsLoadingState && _page == 0)
                _circularProgress();

              if (state is EventsLoadedState) {
                clubEvents = state.events;
                hasReachedMax = state.hasReachedMax;
              }

              final FavouritesEventsCubit favouritesEventsCubit =
                  BlocProvider.of<FavouritesEventsCubit>(context);

              return ListView.builder(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: clubEvents!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 0),
                    child: Align(
                      child: EventItem(
                        event: clubEvents![index],
                        isFavourite: favouritesEventsCubit
                            .checkEventExists(clubEvents![index].eventID),
                      ),
                      alignment: Alignment.topCenter,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
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
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24, top: 12),
            child: Text(
              "Upcoming Events",
              style: TextStyle(
                  color: Colors.white, fontSize: 36, fontFamily: 'LatoBold'),
            ),
          ),
        ],
      ),
    );
  }

  void _blocListener(context, state) {
    if (state is EventsLoadedState) {
      _eventRefreshController.refreshCompleted();

      if (state.hasReachedMax!) _eventRefreshController.loadNoData();
    }
    if (state is EventsErrorState) {
      _eventRefreshController.refreshFailed();
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

  Widget _circularProgress() {
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
        ),
      ),
    );
  }

  ///Build the scroll to top button
  Widget _scrollToTopButton() {
    return AnimatedOpacity(
      opacity: _scrollToTopVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(bottom: 24, right: 24),
          child: Card(
            elevation: 6,
            color: Colors.deepPurple,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
          ),
        ),
      ),
    );
  }
}
