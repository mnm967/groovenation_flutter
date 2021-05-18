import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClubMomentsPage extends StatefulWidget {
  final Club club;
  ClubMomentsPage(this.club);

  @override
  _ClubMomentsPageState createState() => _ClubMomentsPageState(club);
}

class _ClubMomentsPageState extends State<ClubMomentsPage> {
  final Club club;
  _ClubMomentsPageState(this.club);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  final _momentRefreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
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
    final ClubMomentsCubit clubSocialCubit =
        BlocProvider.of<ClubMomentsCubit>(context);
    clubSocialCubit.getMoments(_page, club.clubID);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<SocialPost> clubSocial = [];
  bool hasReachedMax = false;
  int _page = 0;

  _onRefresh() {
    _page = 0;

    final ClubMomentsCubit clubSocialCubit =
        BlocProvider.of<ClubMomentsCubit>(context);
    if (!(clubSocialCubit.state is SocialLoadingState)) {
      clubSocialCubit.getMoments(0, club.clubID);
    }
  }

  _onLoading() {
    if (clubSocial.length == 0 || hasReachedMax) return;

    _page++;
    final ClubMomentsCubit clubSocialCubit =
        BlocProvider.of<ClubMomentsCubit>(context);
    if (!(clubSocialCubit.state is SocialLoadingState)) {
      clubSocialCubit.getMoments(_page, club.clubID);
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
      //       child:
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Row(
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
                      padding: EdgeInsets.only(left: 36, top: 16),
                      child: Text(
                        "Recent Moments",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontFamily: 'LatoBold'),
                      )),
                ],
              ),
              Expanded(
                  child: SmartRefresher(
                      controller: _momentRefreshController,
                      header: WaterDropMaterialHeader(),
                      footer: _classicFooter,
                      onLoading: () => _onLoading(),
                      onRefresh: () => _onRefresh(),
                      enablePullDown: true,
                      enablePullUp: true,
                      child: BlocConsumer<ClubMomentsCubit, SocialState>(
                          listener: (context, state) {
                        if (state is SocialLoadedState) {
                          _momentRefreshController.refreshCompleted();

                          if (state.hasReachedMax)
                            _momentRefreshController.loadNoData();
                        }
                        if (state is SocialErrorState) {
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
                        if (state is SocialLoadingState) {
                          return Padding(
                              padding: EdgeInsets.only(top: 64),
                              child: Center(
                                  child: SizedBox(
                                height: 56,
                                width: 56,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2.0,
                                ),
                              )));
                        }

                        if (state is SocialLoadedState) {
                          clubSocial = state.socialPosts;
                          hasReachedMax = state.hasReachedMax;
                        }

                        return ListView.builder(
                            padding: EdgeInsets.only(top: 12, bottom: 12),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: clubSocial.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: EdgeInsets.fromLTRB(12, 16, 12, 0),
                                  child: Align(
                                    child: SocialItem(
                                        socialPost: clubSocial[index],
                                        showClose: false),
                                    alignment: Alignment.topCenter,
                                  ));
                            });
                      })))
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
}
