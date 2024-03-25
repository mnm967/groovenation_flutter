import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/profile_settings_state.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/cubit/user/profile_settings_cubit.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_grid_item.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_item.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileHomePage extends StatefulWidget {
  final _ProfileHomePageState state = _ProfileHomePageState();

  void runBuild() {
    state.runFirstBuild();
  }

  @override
  _ProfileHomePageState createState() => state;
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  bool isFirstView = true;

  void runFirstBuild() {
    if (isFirstView) {
      _initScrollController();

      isFirstView = false;

      final UserSocialCubit userSocialCubit =
          BlocProvider.of<UserSocialCubit>(context);
      userSocialCubit.getSocialPosts(socialPostsPage);
    } else
      setState(() {});
  }

  final _listRefreshController = RefreshController(initialRefresh: false);
  final _gridRefreshController = RefreshController(initialRefresh: false);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

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

  @override
  void dispose() {
    _listRefreshController.dispose();
    _gridRefreshController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _mainView(context);
  }

  List<SocialPost?>? socialPosts = [];
  int socialPostsPage = 0;

  Widget _sliverAppBar() {
    return SliverAppBar(
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
          ),
        ),
      ),
      flexibleSpace: Stack(
        children: [
          Positioned.fill(
            child: BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
                builder: (context, chatState) {
              return CachedNetworkImage(
                imageUrl: "${sharedPrefs.coverPicUrl}",
                fit: BoxFit.cover,
              );
            }),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Stack(
              children: [SafeArea(child: _topAppBar())],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainView(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: NestedScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [_sliverAppBar()];
              },
              body: TabBarView(
                children: [
                  _socialGridTab(),
                  _socialListTab(),
                ],
              ),
            ),
          ),
          _scrollToTopButton()
        ],
      ),
    );
  }

  Widget _socialListTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            (scrollInfo.metrics.maxScrollExtent - 756)) {
          if (_listRefreshController.footerStatus == LoadStatus.idle) {
            _listRefreshController.requestLoading(needMove: false);
          }
        }
        return false;
      },
      child: BlocBuilder<UserSocialCubit, SocialState>(
          builder: (context, socialState) {
        if (socialState is SocialLoadedState) {
          _listRefreshController.refreshCompleted();
          if (socialState.hasReachedMax!) _listRefreshController.loadNoData();
        }

        return _listRefresher(socialState);
      }),
    );
  }

  Widget _listRefresher(SocialState socialState) {
    return SmartRefresher(
      controller: _listRefreshController,
      header: CustomMaterialClassicHeader(),
      footer: ClassicFooter(
        textStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
            fontFamily: 'Lato'),
        noDataText: "You've reached the end of the line",
        failedText: "Something Went Wrong",
      ),
      onRefresh: () {
        final UserSocialCubit socialCubit =
            BlocProvider.of<UserSocialCubit>(context);

        socialCubit.getSocialPosts(0);
        socialPostsPage = 0;
      },
      onLoading: () {
        if (!(socialState is SocialLoadedState)) {
          _listRefreshController.loadComplete();
          return;
        }

        final UserSocialCubit socialCubit =
            BlocProvider.of<UserSocialCubit>(context);

        socialCubit.getSocialPosts(socialPostsPage + 1);
        socialPostsPage = socialPostsPage + 1;
      },
      enablePullUp: true,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: 24),
            sliver: SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SocialItem(
                        key: Key(socialPosts![index]!.postID!),
                        socialPost: socialPosts![index],
                        showClose: false));
              }, childCount: socialPosts!.length),
            ),
          )
        ],
      ),
    );
  }

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
              child: TextButton(
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

  Widget _socialGridTab() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            (scrollInfo.metrics.maxScrollExtent - 256)) {
          if (_gridRefreshController.footerStatus == LoadStatus.idle) {
            _gridRefreshController.requestLoading(needMove: false);
          }
        }
        return false;
      },
      child: BlocBuilder<UserSocialCubit, SocialState>(
          builder: (context, socialState) {
        if (socialState is SocialLoadedState) {
          if (socialPostsPage == 0)
            socialPosts = socialState.socialPosts;
          else
            socialPosts!.addAll(socialState.socialPosts!);

          _gridRefreshController.refreshCompleted();
          if (socialState.hasReachedMax!) _gridRefreshController.loadNoData();
        }

        return _gridRefresher(socialState);
      }),
    );
  }

  Widget _gridRefresher(SocialState socialState) {
    return SmartRefresher(
      controller: _gridRefreshController,
      header: CustomMaterialClassicHeader(),
      footer: ClassicFooter(
        textStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
            fontFamily: 'Lato'),
        noDataText: "You've reached the end of the line",
        failedText: "Something Went Wrong",
      ),
      onRefresh: () {
        final UserSocialCubit socialCubit =
            BlocProvider.of<UserSocialCubit>(context);

        socialCubit.getSocialPosts(0);
        socialPostsPage = 0;
      },
      onLoading: () {
        if (!(socialState is SocialLoadedState)) {
          _gridRefreshController.loadComplete();
          return;
        }

        final UserSocialCubit socialCubit =
            BlocProvider.of<UserSocialCubit>(context);

        socialCubit.getSocialPosts(socialPostsPage + 1);
        socialPostsPage = socialPostsPage + 1;
      },
      enablePullUp: true,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return SocialGridItem(
                  key: Key(socialPosts![index]!.postID! + "-grid"),
                  socialPost: socialPosts![index]!,
                );
              },
              childCount: socialPosts!.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topAppBar() {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 16, left: 16, right: 0, bottom: 0),
                        child: Container(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: _topAppBarContainer(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _topAppBarContainer() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Wrap(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 116,
                      width: 116,
                      child: BlocBuilder<ProfileSettingsCubit,
                          ProfileSettingsState>(builder: (context, chatState) {
                        return CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              "${sharedPrefs.profilePicUrl}"),
                        );
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24, left: 16, right: 16),
                      child: Text(
                        "${sharedPrefs.username}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: 24),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 8, left: 16, right: 16, bottom: 48),
                      child: Text(
                        "${sharedPrefs.userFollowersCount} ${sharedPrefs.userFollowersCount == 1 ? "Follower" : "Followers"}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'LatoLight',
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.only(right: 8),
                ),
                child: Icon(
                  FontAwesomeIcons.userCog,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
