import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/ui/social/comment_item.dart';
import 'package:groovenation_flutter/ui/social/comments_dialog.dart';
import 'package:groovenation_flutter/ui/social/social_grid_item.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
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
      print("Running Build: ProfileHome");
      isFirstView = false;
    }
  }

  final _listRefreshController = RefreshController(initialRefresh: false);
  final _gridRefreshController = RefreshController(initialRefresh: false);

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
                                                backgroundImage: OptimizedCacheImageProvider(
                                                    'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 24,
                                                    left: 16,
                                                    right: 16,
                                                    bottom: 48),
                                                child: Text(
                                                  "professor_mnm967",
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
                                              Navigator.pushNamed(context, '/settings');
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
                          //"https://jakecoker.files.wordpress.com/2018/09/default-landscapeipad.png?w=1024&h=768&crop=1",
                          imageUrl: "https://images.pexels.com/photos/2204724/pexels-photo-2204724.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500",
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
                body: TabBarView(children: [
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
                    child: SmartRefresher(
                        controller: _gridRefreshController,
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
                            _listRefreshController.loadNoData();
                            print("Finished Loading");
                          });
                        },
                        enablePullUp: true,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                          slivers: [
                            SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return SocialGridItem();
                                  },
                                  childCount: 160,
                                )),
                          ],
                        )),
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
                      child: SmartRefresher(
                          controller: _listRefreshController,
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
                              _listRefreshController.loadNoData();
                              print("Finished Loading");
                            });
                          },
                          enablePullUp: true,
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
                                        padding:
                                            EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: SocialItem(showClose: false));
                                  },
                                  childCount: 8,
                                )),
                              )
                            ],
                          ))),
                ])),
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
