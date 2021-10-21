import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/cubit/user_cubit.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SocialPeopleSearchPage extends StatefulWidget {
  final Function onUserSelected;

  const SocialPeopleSearchPage({Key key, this.onUserSelected}) : super(key: key);

  @override
  _SocialPeopleSearchPageState createState() => _SocialPeopleSearchPageState(onUserSelected);
}

class _SocialPeopleSearchPageState extends State<SocialPeopleSearchPage>
    with SingleTickerProviderStateMixin {
      final Function onUserSelected;

  _SocialPeopleSearchPageState(this.onUserSelected);

  bool _scrollToTopVisible = false;
 
 final searchTextController = TextEditingController();
  TabController _tabController;

  ScrollController _profileScrollController = new ScrollController();
  RefreshController _profileRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 1);

    _profileScrollController.addListener(() {
      if (_profileScrollController.position.pixels <= 30) {
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
    _profileScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.2)),
            child: TextField(
              controller: searchTextController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              autofocus: true,
              cursorColor: Colors.white.withOpacity(0.7),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  final SearchUsersCubit searchUsersCubit =
                        BlocProvider.of<SearchUsersCubit>(context);
                    setState(() {
                      profilePage = 0;
                      searchUsers = [];
                    });

                    _profileRefreshController.loadComplete();

                    searchUsersCubit.searchUsers(0, searchTextController.text);
                }
              },
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
                        color: Colors.white,
                        size: 28,
                      )),
                  prefixIcon: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.only(left: 16, right: 24),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ))),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(FontAwesomeIcons.users),
              text: "People",
            ),
          ],
        )
      ]);

  int profilePage = 0;
  List<SocialPerson> searchUsers = [];

  Widget profileList() {
    return BlocConsumer<SearchUsersCubit, UserState>(
        listener: (context, state) {
      if (state is SocialUsersSearchLoadedState) {
        if (_profileRefreshController.isRefresh) {
          _profileScrollController.jumpTo(0.0);
          _profileRefreshController.refreshCompleted();
          _profileRefreshController.loadComplete();

          _profileRefreshController = RefreshController(initialRefresh: false);
        } else if (_profileRefreshController.isLoading) {
          if (state.hasReachedMax)
            _profileRefreshController.loadNoData();
          else
            _profileRefreshController.loadComplete();
        }
      }
    }, builder: (context, searchUsersState) {
      if (searchUsersState is SocialUsersSearchLoadedState)
        searchUsers = searchUsersState.socialPeople;

      if (searchUsersState is SocialUsersSearchErrorState) {
        switch (searchUsersState.error) {
          case Error.NETWORK_ERROR:
            alertUtil.sendAlert(BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT,
                Colors.red, Icons.error);
            break;
          default:
            alertUtil.sendAlert(BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT,
                Colors.red, Icons.error);
            break;
        }
      }

      return SmartRefresher(
          controller: _profileRefreshController,
          header: WaterDropMaterialHeader(),
          footer: ClassicFooter(
            textStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontFamily: 'Lato'),
            noDataText: "You've reached the end of the line",
            failedText: "Something Went Wrong",
          ),
          onRefresh: () {
            final SearchUsersCubit searchUsersCubit =
                BlocProvider.of<SearchUsersCubit>(context);
            setState(() {
              profilePage = 0;
              searchUsers = [];
            });

            _profileRefreshController.loadComplete();

            searchUsersCubit.searchUsers(0, searchTextController.text);
          },
          onLoading: () {
            if (searchUsers.length == 0) {
              _profileRefreshController.loadComplete();
              return;
            }

            final SearchUsersCubit searchUsersCubit =
                BlocProvider.of<SearchUsersCubit>(context);

            setState(() {
              profilePage++;
            });

            searchUsersCubit.searchUsers(
                profilePage, searchTextController.text);
          },
          enablePullUp: true,
          child: ListView.builder(
              controller: _profileScrollController,
              padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: searchUsers.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: profileItem(context, searchUsers[index]));
              }));
    });
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: DefaultTabController(
          length: 1,
          child: Stack(
            children: [
              Column(
                children: [
                  topAppBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [profileList()],
                    ),
                  )
                ],
              ),
              AnimatedOpacity(
                  opacity: _scrollToTopVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16, right: 16),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(9)),
                          child: FlatButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _profileScrollController.animateTo(
                                0.0,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white.withOpacity(0.7),
                              size: 36,
                            ),
                          ),
                        ),
                      )))
            ],
          )),
    );
  }

  Widget profileItem(BuildContext context, SocialPerson person) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 4,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {
                onUserSelected(person);
                Navigator.pop(context);
              },
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
                                              CachedNetworkImageProvider(
                                                  person.personProfilePicURL),
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
                                                      person.personUsername,
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
