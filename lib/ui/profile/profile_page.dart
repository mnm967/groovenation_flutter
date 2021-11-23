import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/social/profile_social_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/profile_settings_state.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/cubit/user/profile_settings_cubit.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_grid_item.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_item.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {
  final SocialPerson? socialPerson;
  ProfilePage(this.socialPerson);

  @override
  _ProfilePageState createState() => _ProfilePageState(socialPerson);
}

class _ProfilePageState extends State<ProfilePage> {
  final SocialPerson? socialPerson;
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

    socialCubit.getSocialPosts(0, socialPerson!);
  }

  @override
  void dispose() {
    _listRefreshController.dispose();
    _gridRefreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changeUserBlocked() async {
    setState(() {
      socialPerson!.hasUserBlocked = !socialPerson!.hasUserBlocked!;
    });

    final UserSocialCubit userSocialCubit =
        BlocProvider.of<UserSocialCubit>(context);

    bool userBlockSuccess = await userSocialCubit.blockUser(
        context, socialPerson!, socialPerson!.hasUserBlocked!);

    if (!userBlockSuccess)
      setState(() {
        socialPerson!.hasUserBlocked = !socialPerson!.hasUserBlocked!;
      });
  }

  _changeUserFollowingStatus() {
    final ProfileSocialCubit profileSocialCubit =
        BlocProvider.of<ProfileSocialCubit>(context);

    setState(() {
      socialPerson!.isUserFollowing = !socialPerson!.isUserFollowing!;
    });
    profileSocialCubit.updateUserFollowing(context, socialPerson!);
  }

  _openMessages() async {
    final ConversationsCubit conversationsCubit =
        BlocProvider.of<ConversationsCubit>(context);

    Conversation? conversation =
        await conversationsCubit.getPersonConversation(socialPerson!.personID);

    if (conversation == null)
      Navigator.pushNamed(context, '/chat',
          arguments: ChatPageArguments(
              Conversation(null, socialPerson, 0, null), null));
    else
      Navigator.pushNamed(context, '/chat',
          arguments: ChatPageArguments(conversation, null));
  }

  List<SocialPost?>? posts = [];

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
                return [
                  _sliverAppBar(),
                ];
              },
              body: TabBarView(
                children: [
                  _socialGridTab(),
                  _socialListTab(),
                ],
              ),
            ),
          ),
          _scrollToTopButton(),
        ],
      ),
    );
  }

  Widget _sliverAppBar() {
    return SliverAppBar(
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
          ),
        ),
      ),
      flexibleSpace: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: socialPerson!.personCoverPicURL!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Stack(
              children: [
                SafeArea(
                  child: _topAppBar(),
                ),
              ],
            ),
          )
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
      child: BlocBuilder<ProfileSocialCubit, SocialState>(
          builder: (context, socialState) {
        if (socialState is SocialLoadingState && posts!.isEmpty) {
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
        final ProfileSocialCubit socialCubit =
            BlocProvider.of<ProfileSocialCubit>(context);

        socialCubit.getSocialPosts(0, socialPerson!);
        listPage = 0;
      },
      onLoading: () {
        if (!(socialState is SocialLoadedState)) {
          _listRefreshController.loadComplete();
          return;
        }

        final ProfileSocialCubit socialCubit =
            BlocProvider.of<ProfileSocialCubit>(context);

        socialCubit.getSocialPosts(listPage + 1, socialPerson!);
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
                      key: Key((socialState is SocialLoadedState)
                          ? ((posts!.isEmpty)
                              ? socialState.socialPosts![index]!.postID!
                              : posts![index]!.postID!)
                          : posts![index]!.postID!),
                      socialPost: (socialState is SocialLoadedState)
                          ? ((posts!.isEmpty)
                              ? socialState.socialPosts![index]
                              : posts![index])
                          : posts![index],
                      showClose: false),
                );
              },
                  childCount: (socialState is SocialLoadedState)
                      ? ((posts!.isEmpty)
                          ? socialState.socialPosts!.length
                          : posts!.length)
                      : posts!.length),
            ),
          ),
        ],
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
      child: BlocBuilder<ProfileSocialCubit, SocialState>(
          builder: (context, socialState) {
        if (socialState is SocialLoadingState && posts!.isEmpty) {
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

        if (socialState is SocialLoadedState) {
          if (listPage == 0)
            posts = socialState.socialPosts;
          else
            posts!.addAll(socialState.socialPosts!);

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
        final ProfileSocialCubit socialCubit =
            BlocProvider.of<ProfileSocialCubit>(context);

        socialCubit.getSocialPosts(0, socialPerson!);
        listPage = 0;
      },
      onLoading: () {
        if (!(socialState is SocialLoadedState)) {
          _gridRefreshController.loadComplete();
          return;
        }

        final ProfileSocialCubit socialCubit =
            BlocProvider.of<ProfileSocialCubit>(context);

        socialCubit.getSocialPosts(listPage + 1, socialPerson!);
        listPage = listPage + 1;
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
                  key: Key(posts![index]!.postID! + "-grid"),
                  socialPost: posts![index]!,
                );
              },
              childCount: posts!.length,
            ),
          ),
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
                            top: 0, left: 0, right: 0, bottom: 0),
                        child: Container(
                          padding: EdgeInsets.zero,
                          child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: _topAppBarContainer()),
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
        _topAppBarHeader(),
        _blockUserButtons(),
        _topAppBarBackArrow(),
      ],
    );
  }

  Widget _topAppBarBackArrow() {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.only(right: 0, top: 32, bottom: 24),
            child: Icon(
              Icons.arrow_back_ios,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blockUserButtons() {
    return Visibility(
      visible: true,
      child: Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.only(right: 24, top: 24, bottom: 24),
              child: PopupMenuButton<String>(
                onSelected: (item) {
                  if (item == "Block User" || item == "Unblock User") {
                    _changeUserBlocked();
                  }
                },
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, color: Colors.white, size: 32),
                itemBuilder: (BuildContext context) {
                  return {
                    socialPerson!.hasUserBlocked!
                        ? 'Unblock User'
                        : 'Block User'
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice,
                            style: TextStyle(color: Colors.deepPurple)));
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topAppBarHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 24),
        child: Wrap(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 116,
                  width: 116,
                  child:
                      BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
                          builder: (context, chatState) {
                    return CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          socialPerson!.personProfilePicURL!),
                    );
                  }),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 0),
                  child: Text(
                    socialPerson!.personUsername!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Lato', fontSize: 24),
                  ),
                ),
                _topAppBarButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topAppBarButtons() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 3,
      padding: EdgeInsets.only(right: 16, left: 16, top: 24),
      crossAxisCount: 2,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _openMessages();
              },
              child: Text(
                "MESSAGE",
                style: TextStyle(fontFamily: 'LatoBold', color: Colors.white),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12, left: 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white),
              color: socialPerson!.isUserFollowing! ? Colors.white : null,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _changeUserFollowingStatus();
              },
              child: Text(
                socialPerson!.isUserFollowing! ? "UNFOLLOW" : "FOLLOW",
                style: TextStyle(
                    fontFamily: 'LatoBold',
                    color: socialPerson!.isUserFollowing!
                        ? Colors.purple
                        : Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
