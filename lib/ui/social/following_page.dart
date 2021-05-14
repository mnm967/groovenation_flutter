import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/cubit/user_cubit.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:optimized_cached_image/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowingPage extends StatefulWidget {
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  final _followingRefreshController = RefreshController(initialRefresh: false);

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

    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    userCubit.getFollowing(_page);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.2)),
            child: TextField(
              keyboardType: TextInputType.text,
              autofocus: false,
              onChanged: (value) {
                currentSearchTerm = value;
                _page = 0;
                if (value.isEmpty) {
                  final UserCubit userCubit =
                      BlocProvider.of<UserCubit>(context);
                  if (!(userCubit.state is UserFollowingLoadingState))
                    userCubit.getFollowing(_page);
                } else {
                  final UserCubit userCubit =
                      BlocProvider.of<UserCubit>(context);
                  userCubit.searchFollowing(_page, value);
                }
              },
              cursorColor: Colors.white.withOpacity(0.7),
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
                        color: Colors.white.withOpacity(0.2),
                        size: 28,
                      ))),
            ),
          ),
        ),
      ]);

  List<SocialPerson> socialPeople = [];
  bool hasReachedMax = false;
  String currentSearchTerm = "";
  int _page = 0;

  _onRefresh() {
    _page = 0;
    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    if (!(userCubit.state is UserFollowingLoadingState)) {
      if (currentSearchTerm.isEmpty)
        userCubit.getFollowing(_page);
      else
        userCubit.searchFollowing(_page, currentSearchTerm);
    }
  }

  _onLoading() {
    if (socialPeople.length == 0 || hasReachedMax) return;

    _page++;
    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    if (!(userCubit.state is UserFollowingLoadingState)) {
      if (currentSearchTerm.isEmpty)
        userCubit.getFollowing(_page);
      else
        userCubit.searchFollowing(_page, currentSearchTerm);
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
      CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
                                padding: EdgeInsets.zero,
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
                              "Following",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'LatoBold'),
                            )),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: topAppBar(),
                    ),
                    BlocConsumer<UserCubit, UserState>(
                        listener: (context, state) {
                      if (state is UserFollowingErrorState) {
                        switch (state.error) {
                          case Error.NETWORK_ERROR:
                            alertUtil.sendAlert(BASIC_ERROR_TITLE,
                                NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
                            break;
                          default:
                            alertUtil.sendAlert(BASIC_ERROR_TITLE,
                                UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
                            break;
                        }
                      }
                    }, builder: (context, state) {
                      if (state is UserFollowingLoadingState) {
                        return Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: Center(
                                child: SizedBox(
                              height: 56,
                              width: 56,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.0,
                              ),
                            )));
                      }

                      if (state is UserFollowingLoadedState) {
                        if (_page == 0)
                          socialPeople = state.socialPeople;
                        else
                          socialPeople.addAll(state.socialPeople);

                        hasReachedMax = state.hasReachedMax;
                      }

                      return SmartRefresher(
                          controller: _followingRefreshController,
                          header: WaterDropMaterialHeader(),
                          footer: _classicFooter,
                          onLoading: _onLoading(),
                          onRefresh: _onRefresh(),
                          enablePullDown: false,
                          enablePullUp: true,
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 12, bottom: 12),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: socialPeople.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: Align(
                                      child: profileItem(
                                          context, socialPeople[index]),
                                      alignment: Alignment.topCenter,
                                    ));
                              }));
                    })
                  ],
                )),
          )
        ],
      ),
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

  Widget profileItem(BuildContext context, SocialPerson socialPerson) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 3,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {},
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
                                              OptimizedCacheImageProvider(
                                                  socialPerson
                                                      .personCoverPicURL),
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
                                                      socialPerson
                                                          .personUsername,
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
