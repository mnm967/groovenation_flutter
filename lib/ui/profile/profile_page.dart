import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_grid_item.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {
  final SocialPerson socialPerson;
  ProfilePage(this.socialPerson);

  @override
  _ProfilePageState createState() => _ProfilePageState(socialPerson);
}

class _ProfilePageState extends State<ProfilePage> {
  final SocialPerson socialPerson;
  _ProfilePageState(this.socialPerson);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  final _listRefreshController = RefreshController(initialRefresh: false);
  final _gridRefreshController = RefreshController(initialRefresh: false);

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

    final ProfileSocialCubit socialCubit =
        BlocProvider.of<ProfileSocialCubit>(context);

    socialCubit.getSocialPosts(0, socialPerson);
  }

  @override
  void dispose() {
    _listRefreshController.dispose();
    _gridRefreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _changeUserBlocked() {
    //TODO Block/Unblock User
  }

  _changeUserFollowingStatus() {
    final ProfileSocialCubit profileSocialCubit =
        BlocProvider.of<ProfileSocialCubit>(context);

    socialPerson.isUserFollowing = !socialPerson.isUserFollowing;
    profileSocialCubit.updateUserFollowing(context, socialPerson);

    setState(() {});
  }

  _openMessages() {
    //TODO Open Messages
  }

  List<SocialPost> posts = [];

  Stack topAppBar() => Stack(children: [
        Row(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
            child: Container(
                child: Stack(
              children: [
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                    child: Container(
                        padding: EdgeInsets.zero,
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 24),
                                      child: Wrap(children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 116,
                                              width: 116,
                                              child: CircleAvatar(
                                                backgroundImage:
                                                    OptimizedCacheImageProvider(
                                                        socialPerson
                                                            .personProfilePicURL),
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 24,
                                                    left: 16,
                                                    right: 16,
                                                    bottom: 0),
                                                child: Text(
                                                  socialPerson.personUsername,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Lato',
                                                      fontSize: 24),
                                                )),
                                            GridView.count(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                childAspectRatio: 3,
                                                padding: EdgeInsets.only(
                                                    right: 16,
                                                    left: 16,
                                                    top: 24),
                                                crossAxisCount: 2,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12, right: 8),
                                                    child: Container(
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 1.0,
                                                              color:
                                                                  Colors.white),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10.0)),
                                                        ),
                                                        child: FlatButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          onPressed: () {
                                                            _openMessages();
                                                          },
                                                          child: Text(
                                                            "MESSAGE",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LatoBold',
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 12, left: 8),
                                                    child: Container(
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 1.0,
                                                              color:
                                                                  Colors.white),
                                                          color: socialPerson
                                                                  .isUserFollowing
                                                              ? Colors.white
                                                              : null,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10.0)),
                                                        ),
                                                        child: FlatButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          onPressed: () {
                                                            _changeUserFollowingStatus();
                                                          },
                                                          child: Text(
                                                            socialPerson
                                                                    .isUserFollowing
                                                                ? "UNFOLLOW"
                                                                : "FOLLOW",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'LatoBold',
                                                                color: socialPerson
                                                                        .isUserFollowing
                                                                    ? Colors
                                                                        .purple
                                                                    : Colors
                                                                        .white),
                                                          ),
                                                        )),
                                                  )
                                                ]),
                                          ],
                                        )
                                      ])),
                                ),
                                Visibility(
                                    visible: true,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  right: 24,
                                                  top: 24,
                                                  bottom: 24),
                                              child: PopupMenuButton<String>(
                                                onSelected: (item) {
                                                  if (item == "Block User" ||
                                                      item == "Unblock User") {
                                                    _changeUserBlocked();
                                                  }
                                                },
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.more_vert,
                                                    color: Colors.white,
                                                    size: 32),
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return {'Block User'}
                                                      .map((String choice) {
                                                    return PopupMenuItem<
                                                            String>(
                                                        value: choice,
                                                        child: Text(choice,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .deepPurple)));
                                                  }).toList();
                                                },
                                              ),
                                            ),
                                          ]),
                                    )),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            padding: EdgeInsets.only(
                                                right: 0, top: 32, bottom: 24),
                                            child: Icon(
                                              Icons.arrow_back_ios,
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

  int listPage = 0;

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
                      automaticallyImplyLeading: false,
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
                        // Positioned.fill(
                        //     child: OptimizedCacheImage(
                        //   imageUrl: socialPerson.personCoverPicURL,
                        //   fit: BoxFit.cover,
                        // )),
                        Positioned.fill(
                            child: Image.network(
                          socialPerson.personCoverPicURL,
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
                        _gridRefreshController.requestLoading(needMove: false);
                      }
                    }
                    return false;
                  }, child: BlocBuilder<ProfileSocialCubit, SocialState>(
                          builder: (context, socialState) {
                    if (socialState is SocialLoadedState) {
                      if (listPage == 0)
                        posts = socialState.socialPosts;
                      else
                        posts.addAll(socialState.socialPosts);

                      _gridRefreshController.refreshCompleted();
                      if (socialState.hasReachedMax)
                        _gridRefreshController.loadNoData();
                    }
                    return SmartRefresher(
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
                          if (!(socialState is SocialLoadedState)) {
                            _gridRefreshController.loadComplete();
                            return;
                          }

                          final ProfileSocialCubit socialCubit =
                              BlocProvider.of<ProfileSocialCubit>(context);

                          socialCubit.getSocialPosts(
                              listPage + 1, socialPerson);
                          listPage = listPage + 1;
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
                                    return SocialGridItem(
                                      key: Key(posts[index].postID + "-grid"),
                                      socialPost: posts[index],
                                    );
                                  },
                                  childCount: posts.length,
                                )),
                          ],
                        ));
                  })),
                  NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        (scrollInfo.metrics.maxScrollExtent - 756)) {
                      if (_listRefreshController.footerStatus ==
                          LoadStatus.idle) {
                        _listRefreshController.requestLoading(needMove: false);
                      }
                    }
                    return false;
                  }, child: BlocBuilder<ProfileSocialCubit, SocialState>(
                          builder: (context, socialState) {
                    if (socialState is SocialLoadedState) {
                      // if (listPage == 0)
                      //   posts = socialState.socialPosts;
                      // else
                      //   posts.addAll(socialState.socialPosts);

                      _listRefreshController.refreshCompleted();
                      if (socialState.hasReachedMax)
                        _listRefreshController.loadNoData();
                    }

                    return SmartRefresher(
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
                          if (!(socialState is SocialLoadedState)) {
                            _listRefreshController.loadComplete();
                            return;
                          }

                          final ProfileSocialCubit socialCubit =
                              BlocProvider.of<ProfileSocialCubit>(context);

                          socialCubit.getSocialPosts(
                              listPage + 1, socialPerson);
                          listPage = listPage + 1;
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
                                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: SocialItem(
                                        key: Key(posts[index].postID),
                                        socialPost: posts[index],
                                        showClose: false));
                              }, childCount: posts.length)),
                            )
                          ],
                        ));
                  })),
                ])
                ),
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

  // Widget mainView(BuildContext context) {
  //   return DefaultTabController(
  //       length: 2,
  //       child: Stack(children: [
  //         Scaffold(
  //           backgroundColor: Colors.transparent,
  //           body: NestedScrollView(
  //             controller: _scrollController,
  //             physics: const BouncingScrollPhysics(
  //                 parent: AlwaysScrollableScrollPhysics()),
  //             headerSliverBuilder:
  //                 (BuildContext context, bool innerBoxIsScrolled) {
  //               return <Widget>[
  //                 SliverAppBar(
  //                   expandedHeight: 372.0,
  //                   floating: false,
  //                   pinned: false,
  //                   backgroundColor: Colors.transparent,
  //                   bottom: PreferredSize(
  //                       preferredSize: new Size(0, 24),
  //                       child: Container(
  //                           height: 72,
  //                           child: TabBar(
  //                             indicatorColor: Colors.purple,
  //                             tabs: [
  //                               Tab(
  //                                 icon: FaIcon(
  //                                   FontAwesomeIcons.thLarge,
  //                                   size: 24,
  //                                 ),
  //                               ),
  //                               Tab(
  //                                 icon: FaIcon(
  //                                   FontAwesomeIcons.bars,
  //                                   size: 24,
  //                                 ),
  //                               ),
  //                             ],
  //                           ))),
  //                   flexibleSpace: Stack(children: [
  //                     Positioned.fill(
  //                         child: Image.network(
  //                       "https://jakecoker.files.wordpress.com/2018/09/default-landscapeipad.png?w=1024&h=768&crop=1",
  //                       fit: BoxFit.cover,
  //                     )),
  //                     Positioned.fill(
  //                       child: Container(
  //                         color: Colors.black.withOpacity(0.5),
  //                       ),
  //                     ),
  //                     FlexibleSpaceBar(
  //                         collapseMode: CollapseMode.pin,
  //                         background: Stack(
  //                           children: [SafeArea(child: topAppBar())],
  //                         ))
  //                   ]),
  //                 ),
  //               ];
  //             },
  //             body: TabBarView(
  //               //physics: NeverScrollableScrollPhysics(),
  //               children: [
  //                 Container(
  //                   height: MediaQuery.of(context).size.height - 96,
  //                   child: SmartRefresher(
  //                     controller: RefreshController(initialRefresh: false),
  //                     header: WaterDropMaterialHeader(),
  //                     enablePullUp: true,
  //                     onLoading: () {
  //                       print("Loading Grid");
  //                     },
  //                     child: imagesGrid(),
  //                   ),
  //                 ),
  //                 Container(
  //                   height: MediaQuery.of(context).size.height - 96,
  //                   child: SmartRefresher(
  //                     controller: RefreshController(initialRefresh: false),
  //                     header: WaterDropMaterialHeader(),
  //                     enablePullUp: true,
  //                     onLoading: () {
  //                       print("Loading List");
  //                     },
  //                     child: socialList(),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         AnimatedOpacity(
  //             opacity: _scrollToTopVisible ? 1.0 : 0.0,
  //             duration: Duration(milliseconds: 250),
  //             child: Align(
  //                 alignment: Alignment.bottomRight,
  //                 child: Padding(
  //                     padding: EdgeInsets.only(bottom: 24, right: 24),
  //                     child: Card(
  //                       elevation: 6,
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(9)),
  //                       child: Container(
  //                         height: 48,
  //                         width: 48,
  //                         decoration: BoxDecoration(
  //                             color: Colors.deepPurple,
  //                             borderRadius: BorderRadius.circular(9)),
  //                         child: FlatButton(
  //                           padding: EdgeInsets.zero,
  //                           onPressed: () {
  //                             _scrollController.animateTo(
  //                               0.0,
  //                               curve: Curves.easeOut,
  //                               duration: const Duration(milliseconds: 300),
  //                             );
  //                           },
  //                           child: Icon(
  //                             Icons.keyboard_arrow_up,
  //                             color: Colors.white.withOpacity(0.8),
  //                             size: 36,
  //                           ),
  //                         ),
  //                       ),
  //                     ))))
  //       ]));
  // }

  Widget socialList() {
    return ListView.builder(
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 16), child: socialItem(context));
        });
  }

  Widget imagesGrid() {
    return GridView.builder(
        itemCount: 160,
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return OptimizedCacheImage(
              imageUrl:
                  'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=250&w=420',
              imageBuilder: (context, imageProvider) => Ink.image(
                image: imageProvider,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {},
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7)),
                strokeWidth: 2,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: Colors.white,
                size: 56,
              ),
            );
          }
          return OptimizedCacheImage(
            imageUrl:
                'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=250&w=420',
            imageBuilder: (context, imageProvider) => Ink.image(
              image: imageProvider,
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () {},
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.7)),
              strokeWidth: 2,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.error,
              color: Colors.white,
              size: 56,
            ),
          );
        });
  }

  Widget socialItem(BuildContext context) {
    return Wrap(children: [
      Container(
        child: Card(
          color: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
              child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 64,
                          width: 64,
                          child: CircleAvatar(
                            backgroundColor: Colors.purple.withOpacity(0.5),
                            backgroundImage: OptimizedCacheImageProvider(
                                'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                            child: FlatButton(
                                onPressed: () {}, child: Container()),
                          )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(left: 16, top: 0, right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "professor_mnm967",
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'LatoBold',
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_bar,
                                        size: 20,
                                        color: Colors.white.withOpacity(0.4)),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Jive Lounge",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          onSelected: (item) {},
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_vert,
                              color: Colors.white, size: 28),
                          itemBuilder: (BuildContext context) {
                            return {'Report'}.map((String choice) {
                              return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice,
                                      style:
                                          TextStyle(color: Colors.deepPurple)));
                            }).toList();
                          },
                        ),
                      )
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 0),
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          GestureDetector(
                              onDoubleTap: () {
                                print("double");
                              },
                              child: Stack(
                                children: [
                                  CroppedCacheImage(
                                      url:
                                          'https://c-sf.smule.com/rs-s78/arr/ea/63/5ea2c2ee-8088-4068-bc4f-4a46a2912a7d_1024.jpg'),
                                  Container(
                                    child: Center(
                                      child: SizedBox(
                                        width: 128,
                                        height: 128,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Visibility(
                              visible: false,
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2),
                                    child: Center(
                                      child: Icon(
                                        FontAwesomeIcons.play,
                                        color: Colors.white,
                                        size: 84,
                                      ),
                                    ),
                                  )))
                        ],
                      ))),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.heart,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {}),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.comment,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {}),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.shareSquare,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {}),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    "400 likes",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 18,
                        fontFamily: 'Lato'),
                  ),
                ),
              ),
              CommentItem(),
            ],
          )),
        ),
      )
    ]);
  }
}

class CommentItem extends StatefulWidget {
  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool currentMaxLines = false;

  @override
  void initState() {
    super.initState();
    currentMaxLines = false;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        setState(() {
          currentMaxLines = !currentMaxLines;
        });
      },
      padding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
            child: RichText(
              maxLines: currentMaxLines ? 10000000 : 3,
              overflow: TextOverflow.ellipsis,
              text: new TextSpan(
                style: new TextStyle(
                    color: Colors.white, fontSize: 16, fontFamily: 'LatoLight'),
                children: <TextSpan>[
                  new TextSpan(
                      text: 'professor_mnm967',
                      style: new TextStyle(fontFamily: 'LatoBlack')),
                  new TextSpan(
                      text:
                          '\tLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
                ],
              ),
            )),
      ),
    );
  }
}
