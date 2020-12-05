import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/ui/social/social_grid_item.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:optimized_cached_image/image_provider/optimized_cached_image_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SocialHomePage extends StatefulWidget {
  final _SocialHomePageState state = _SocialHomePageState();

  void runBuild() {
    state.runBuild();
  }

  @override
  _SocialHomePageState createState() {
    return state;
  }
}

class _SocialHomePageState extends State<SocialHomePage> {
  bool isFirstView = true;

  runBuild() {
    if (isFirstView) {
      print("Running Build: SocialHome");
      isFirstView = false;
    }
  }

  final _nearbyRefreshController = RefreshController(initialRefresh: false);
  final _trendingRefreshController = RefreshController(initialRefresh: false);
  final _followingRefreshController = RefreshController(initialRefresh: false);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

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
  }

  @override
  void dispose() {
    _nearbyRefreshController.dispose();
    _trendingRefreshController.dispose();
    _followingRefreshController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  openSearchPage() {
    Navigator.pushNamed(context, '/search');
  }

  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                openSearchPage();
              },
              child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white.withOpacity(0.2)),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Text(
                            "Search",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontFamily: 'Lato',
                                fontSize: 17),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: Icon(
                              Icons.search,
                              size: 28,
                              color: Colors.white.withOpacity(0.5),
                            )),
                      ),
                    ],
                  ))),
        ),
        TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.local_bar),
              text: "Nearby",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.solidHeart),
              text: "Following",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.fire),
              text: "Trending",
            ),
          ],
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
            length: 3,
            initialIndex: 1,
            child: Column(
              children: [
                topAppBar(),
                Expanded(
                  child: TabBarView(children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                            (scrollInfo.metrics.maxScrollExtent - 256)) {
                          if (_nearbyRefreshController.footerStatus ==
                              LoadStatus.idle) {
                            _nearbyRefreshController.requestLoading(
                                needMove: false);
                          }
                        }
                        return false;
                      },
                      child: SmartRefresher(
                          controller: _nearbyRefreshController,
                          header: WaterDropMaterialHeader(),
                          footer: ClassicFooter(
                            textStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontFamily: 'Lato'),
                            noDataText: "You've reached the end of the line",
                            failedText: "Something Went Wrong",
                          ),
                          onLoading: () {
                            print("Started Loading");
                            Future.delayed(const Duration(seconds: 5), () {
                              // setState(() {
                              //   upcomingCount = upcomingCount + 4;
                              // });
                              _nearbyRefreshController.loadNoData();
                              print("Finished Loading");
                            });
                          },
                          enablePullUp: true,
                          child: CustomScrollView(
                            key: Key("NearbySocialHomeScrollView"),
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.only(top: 24),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: SocialItem(showClose: false));
                                  },
                                  childCount: 8,
                                )),
                              )
                            ],
                          )),
                    ),
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                            (scrollInfo.metrics.maxScrollExtent - 756)) {
                          if (_followingRefreshController.footerStatus ==
                              LoadStatus.idle) {
                            _followingRefreshController.requestLoading(
                                needMove: false);
                          }
                        }
                        return false;
                      },
                      child: SmartRefresher(
                          controller: _followingRefreshController,
                          header: WaterDropMaterialHeader(),
                          footer: ClassicFooter(
                            textStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontFamily: 'Lato'),
                            noDataText: "You've reached the end of the line",
                            failedText: "Something Went Wrong",
                          ),
                          onLoading: () {
                            print("Started Loading");
                            Future.delayed(const Duration(seconds: 5), () {
                              // setState(() {
                              //   upcomingCount = upcomingCount + 4;
                              // });
                              _followingRefreshController.loadNoData();
                              print("Finished Loading");
                            });
                          },
                          enablePullUp: true,
                          child: CustomScrollView(
                            key: Key("FollowingSocialHomeScrollView"),
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.only(top: 24),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            16, 0, 16, 16),
                                        child: SocialItem(showClose: false));
                                  },
                                  childCount: 8,
                                )),
                              )
                            ],
                          ))),
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                            (scrollInfo.metrics.maxScrollExtent - 256)) {
                          if (_trendingRefreshController.footerStatus ==
                              LoadStatus.idle) {
                            _trendingRefreshController.requestLoading(
                                needMove: false);
                          }
                        }
                        return false;
                      },
                      child: SmartRefresher(
                          controller: _trendingRefreshController,
                          header: WaterDropMaterialHeader(),
                          footer: ClassicFooter(
                            textStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontFamily: 'Lato'),
                            noDataText: "You've reached the end of the line",
                            failedText: "Something Went Wrong",
                          ),
                          onLoading: () {
                            print("Started Loading");
                            Future.delayed(const Duration(seconds: 5), () {
                              // setState(() {
                              //   upcomingCount = upcomingCount + 4;
                              // });
                              _trendingRefreshController.loadNoData();
                              print("Finished Loading");
                            });
                          },
                          enablePullUp: true,
                          child: CustomScrollView(
                            key: Key("TrendingSocialHomeScrollView"),
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.only(top: 24),
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: SocialItem(showClose: false));
                                  },
                                  childCount: 8,
                                )),
                              )
                            ],
                          )),
                    ),
                  ]),
                )
              ],
            )));
  }
}
