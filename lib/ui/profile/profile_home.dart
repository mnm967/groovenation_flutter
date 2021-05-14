import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_grid_item.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileHomePage extends StatefulWidget {
  final _ProfileHomePageState state = _ProfileHomePageState();

  void runBuild() {
    state.runBuild();
  }

  @override
  _ProfileHomePageState createState() => state;
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  bool isFirstView = true;

  runBuild() {
    if (isFirstView) {
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

      print("Running Build: ProfileHome");
      isFirstView = false;

      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);
      userSocialCubit.getSocialPosts(socialPostsPage);
    }
  }

  final _listRefreshController = RefreshController(initialRefresh: false);
  final _gridRefreshController = RefreshController(initialRefresh: true);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels <= 30) {
    //     if (_scrollToTopVisible != false) {
    //       setState(() {
    //         _scrollToTopVisible = false;
    //       });
    //     }
    //   } else {
    //     if (_scrollToTopVisible != true) {
    //       setState(() {
    //         _scrollToTopVisible = true;
    //       });
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    _listRefreshController.dispose();
    _gridRefreshController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  Stack topAppBar() => Stack(children: [
        Row(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
            child: Container(
                child: Stack(
              children: [
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
                    child: Container(
                        padding: EdgeInsets.zero,
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                      padding: EdgeInsets.zero,
                                      child: Wrap(children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 116,
                                              width: 116,
                                              child: CircleAvatar(
                                                  backgroundImage:
                                                      OptimizedCacheImageProvider(
                                                          "${sharedPrefs.profilePicUrl}")),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 24,
                                                    left: 16,
                                                    right: 16,
                                                    bottom: 48),
                                                child: Text(
                                                  "${sharedPrefs.username}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Lato',
                                                      fontSize: 24),
                                                )),
                                          ],
                                        )
                                      ])),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/settings');
                                            },
                                            padding: EdgeInsets.only(right: 8),
                                            child: Icon(
                                              FontAwesomeIcons.userCog,
                                              size: 28,
                                              color: Colors.white,
                                            )),
                                      ]),
                                ),
                              ],
                            ))),
                  ),
                ),
              ],
            )),
          ),
        ]),
      ]);

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return mainView(context);
  }

  List<SocialPost> socialPosts = [];
  int socialPostsPage = 0;

  Widget mainView(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Stack(children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: NestedScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 372.0,
                      floating: false,
                      pinned: false,
                      leading: Container(),
                      backgroundColor: Colors.transparent,
                      bottom: PreferredSize(
                          preferredSize: new Size(0, 24),
                          child: Container(
                              height: 72,
                              child: TabBar(
                                onTap: (index) {},
                                indicatorColor: Colors.purple,
                                tabs: [
                                  Tab(
                                    icon: FaIcon(
                                      FontAwesomeIcons.thLarge,
                                      size: 24,
                                    ),
                                  ),
                                  Tab(
                                    icon: FaIcon(
                                      FontAwesomeIcons.bars,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ))),
                      flexibleSpace: Stack(children: [
                        Positioned.fill(
                            child: OptimizedCacheImage(
                          imageUrl: "${sharedPrefs.coverPicUrl}",
                          fit: BoxFit.cover,
                        )),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: Stack(
                              children: [SafeArea(child: topAppBar())],
                            ))
                      ]),
                    ),
                  ];
                },
                body: BlocConsumer<UserSocialCubit, SocialState>(
                    listener: (context, socialState) {
                  if (socialState is SocialLoadedState) {
                    _listRefreshController.refreshCompleted();
                    if (socialState.socialPosts.length > 0 &&
                        socialPostsPage == 0)
                      _listRefreshController.loadComplete();
                    else
                      _listRefreshController.loadNoData();

                    _gridRefreshController.refreshCompleted();
                    if (socialState.socialPosts.length > 0 &&
                        socialPostsPage == 0)
                      _gridRefreshController.loadComplete();
                    else
                      _gridRefreshController.loadNoData();
                  }

                  if (socialState is SocialErrorState) {
                    _listRefreshController.refreshFailed();
                    _listRefreshController.loadFailed();

                    _gridRefreshController.refreshFailed();
                    _gridRefreshController.loadFailed();
                  }
                }, builder: (context, socialState) {
                  bool hasReachedMax = false;

                  if (socialState is SocialLoadedState) {
                    socialPosts = socialState.socialPosts;
                    // if (socialPostsPage == 0)
                    //   socialPosts = socialState.socialPosts;
                    // else {
                    //   socialPosts.addAll(socialState.socialPosts);
                    // }
                    hasReachedMax = socialState.hasReachedMax;
                  }

                  return TabBarView(children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                            (scrollInfo.metrics.maxScrollExtent - 256)) {
                          if (_gridRefreshController.footerStatus ==
                              LoadStatus.idle) {
                            _gridRefreshController.requestLoading(
                                needMove: false);
                          }
                        }
                        return false;
                      },
                      child: SocialGridList(
                          socialPosts, hasReachedMax, _gridRefreshController,
                          () {
                        final UserSocialCubit socialCubit =
                            BlocProvider.of<UserSocialCubit>(context);

                        if ((socialCubit.state is SocialLoadedState ||
                                socialCubit.state is SocialErrorState) &&
                            !isFirstView) {
                          socialPostsPage = 0;
                          socialCubit.getSocialPosts(socialPostsPage);
                        }
                      }, () {
                        final UserSocialCubit socialCubit =
                            BlocProvider.of<UserSocialCubit>(context);

                        socialPostsPage++;
                        socialCubit.getSocialPosts(socialPostsPage);
                      }),
                    ),
                    NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              (scrollInfo.metrics.maxScrollExtent - 756)) {
                            if (_listRefreshController.footerStatus ==
                                LoadStatus.idle) {
                              _listRefreshController.requestLoading(
                                  needMove: false);
                            }
                          }
                          return false;
                        },
                        child: SocialPostList(
                            socialPosts, hasReachedMax, _listRefreshController,
                            () {
                          final UserSocialCubit socialCubit =
                              BlocProvider.of<UserSocialCubit>(context);

                          if ((socialCubit.state is SocialLoadedState ||
                                  socialCubit.state is SocialErrorState) &&
                              !isFirstView) {
                            socialPostsPage = 0;
                            socialCubit.getSocialPosts(socialPostsPage);
                          }
                        }, () {
                          final UserSocialCubit socialCubit =
                              BlocProvider.of<UserSocialCubit>(context);

                          socialPostsPage++;
                          socialCubit.getSocialPosts(socialPostsPage);
                        })),
                  ]);
                })),
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
}

class SocialPostList extends StatefulWidget {
  final List<SocialPost> socialPosts;
  final bool isCompleted;
  final RefreshController refreshController;
  final Function onRefresh;
  final Function onLoading;

  SocialPostList(this.socialPosts, this.isCompleted, this.refreshController,
      this.onRefresh, this.onLoading);

  @override
  _SocialListState createState() {
    final _SocialListState state = _SocialListState(
        socialPosts, isCompleted, refreshController, onRefresh, onLoading);
    return state;
  }
}

class _SocialListState extends State<SocialPostList>
    with AutomaticKeepAliveClientMixin<SocialPostList> {
  List<SocialPost> socialPosts;
  bool isCompleted;
  RefreshController refreshController;
  Function onRefresh;
  Function onLoading;

  _SocialListState(this.socialPosts, this.isCompleted, this.refreshController,
      this.onRefresh, this.onLoading);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
        controller: refreshController,
        header: WaterDropMaterialHeader(),
        footer: ClassicFooter(
          textStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontFamily: 'Lato'),
          noDataText: "Nothing to See Here",
          failedText: "Something Went Wrong",
        ),
        onLoading: onLoading,
        onRefresh: onRefresh,
        enablePullUp: true,
        enablePullDown: true,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: 24),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SocialItem(
                          socialPost: socialPosts[index], showClose: false));
                },
                childCount: socialPosts.length,
              )),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class SocialGridList extends StatefulWidget {
  final List<SocialPost> socialPosts;
  final bool isCompleted;
  final RefreshController refreshController;
  final Function onRefresh;
  final Function onLoading;

  SocialGridList(this.socialPosts, this.isCompleted, this.refreshController,
      this.onRefresh, this.onLoading);

  @override
  _SocialGridListState createState() {
    final _SocialGridListState state = _SocialGridListState(
        socialPosts, isCompleted, refreshController, onRefresh, onLoading);
    return state;
  }
}

class _SocialGridListState extends State<SocialGridList>
    with AutomaticKeepAliveClientMixin<SocialGridList> {
  List<SocialPost> socialPosts;
  bool isCompleted;
  RefreshController refreshController;
  Function onRefresh;
  Function onLoading;

  _SocialGridListState(this.socialPosts, this.isCompleted,
      this.refreshController, this.onRefresh, this.onLoading);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
        controller: refreshController,
        header: WaterDropMaterialHeader(),
        footer: ClassicFooter(
          textStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontFamily: 'Lato'),
          noDataText: "Nothing to See Here",
          failedText: "Something Went Wrong",
        ),
        onLoading: () => {
          onLoading()
          },
        onRefresh: () => onRefresh(),
        enablePullUp: true,
        enablePullDown: true,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPadding(
                padding: socialPosts.length == 0
                    ? EdgeInsets.only(top: 24)
                    : EdgeInsets.zero,
                sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return SocialGridItem(socialPost: socialPosts[index]);
                      },
                      childCount: socialPosts.length,
                    ))),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
