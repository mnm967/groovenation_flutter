import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/profile/widgets/social_post_list.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_item.dart';
import 'package:groovenation_flutter/ui/social/widgets/trimmer_view.dart';
import 'package:groovenation_flutter/util/create_post_arguments.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:groovenation_flutter/widgets/expandable_fab.dart';
import 'package:groovenation_flutter/widgets/filters/filter_widget.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:file_picker/file_picker.dart';

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

class _SocialHomePageState extends State<SocialHomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<State> _loadingDialogKey = new GlobalKey<State>();
  bool _isFirstView = true;

  final picker = ImagePicker();

  final _nearbyRefreshController = RefreshController(initialRefresh: true);
  final _trendingRefreshController = RefreshController(initialRefresh: true);
  final _followingRefreshController = RefreshController(initialRefresh: true);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  TabController? _tabController;

  void _initScrollController() {
    _scrollController.addListener(
      () {
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
      },
    );
  }

  void runBuild() {
    if (_isFirstView) {
      _initScrollController();

      setState(() {
        _isFirstView = false;
      });

      _runGetSocialPosts();
    }
  }

  void _runGetSocialPosts() {
    final NearbySocialCubit nearbySocialCubit =
        BlocProvider.of<NearbySocialCubit>(context);
    nearbySocialCubit.getSocialPosts(nearbyPage);

    final FollowingSocialCubit followingSocialCubit =
        BlocProvider.of<FollowingSocialCubit>(context);
    followingSocialCubit.getSocialPosts(followingPage);

    final TrendingSocialCubit trendingSocialCubit =
        BlocProvider.of<TrendingSocialCubit>(context);
    trendingSocialCubit.getSocialPosts(trendingPage);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 1,
    );
  }

  @override
  void dispose() {
    _nearbyRefreshController.dispose();
    _trendingRefreshController.dispose();
    _followingRefreshController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  void _openSearchPage() {
    Navigator.pushNamed(context, '/search');
  }

  Future<void> _showLoadingDialog(BuildContext context, String text) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(_loadingDialogKey, text);
        });
  }

  Future<void> _hideLoadingDialog() async {
    Navigator.of(_loadingDialogKey.currentContext!, rootNavigator: true).pop();
  }

  Future<void> _chooseSocialImage(bool isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedFile == null) return;

    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop & Rotate',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    String imgPath = croppedFile!.path;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext con) => FilterWidget(
          imagePath: imgPath,
          onImagePicked: (path) async {
            File newFile = File(path);

            if (newFile.lengthSync() > 2000000) {
              _showLoadingDialog(context, "Preparing Media...");
              imgPath = (await _compressAndGetFile(newFile,
                      "${newFile.parent.path}/compressed-${newFile.path.split('/').last}"))!
                  .path;
              _hideLoadingDialog();
            }

            Navigator.pop(context);

            Navigator.pushNamed(
              context,
              '/create_post',
              arguments: CreatePostArguments(path, false),
            );
          },
        ),
      ),
    );
  }

  Future<File?> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstView) return Container();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: ExpandableFab(
        distance: 84.0,
        children: [
          ActionButton(
            icon: const Icon(FontAwesomeIcons.cameraRetro),
            onPressed: () {
              _tabController!.animateTo(1);
              _chooseSocialImage(true);
            },
          ),
          ActionButton(
            icon: const Icon(FontAwesomeIcons.images),
            onPressed: () {
              _tabController!.animateTo(1);
              _chooseSocialImage(false);
            },
          ),
          ActionButton(
            icon: const Icon(FontAwesomeIcons.video),
            onPressed: _createVideoPost,
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Column(
            children: [
              _topAppBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _nearbySocialPostList(),
                    _followingSocialPostList(),
                    _trendingSocialPostList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchButtonField() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
        child: TextButton(
          onPressed: _openSearchPage,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _conversationsButton() {
    return Expanded(
      flex: 0,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/conversations');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white.withOpacity(0.2),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.send,
              size: 28,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topAppBar() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            _searchButtonField(),
            _conversationsButton(),
          ],
        ),
        TabBar(
          controller: _tabController,
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
        ),
      ],
    );
  }

  Function getBlocListener(RefreshController refreshController) {
    return (context, socialState) {
      if (socialState is SocialLoadedState) {
        refreshController.refreshCompleted();

        if (socialState.hasReachedMax!)
          refreshController.loadNoData();
        else
          refreshController.loadComplete();
      }

      if (socialState is SocialErrorState) {
        refreshController.refreshCompleted();
        refreshController.refreshFailed();
        refreshController.loadFailed();
      }
    };
  }

  Function getScrollNotificationListener(RefreshController refreshController) {
    return (ScrollNotification scrollInfo) {
      if (scrollInfo.metrics.pixels >=
          (scrollInfo.metrics.maxScrollExtent - 256)) {
        if (refreshController.footerStatus == LoadStatus.idle) {
          refreshController.requestLoading(needMove: false);
        }
      }
      return false;
    };
  }

  void _createVideoPost() async {
    _tabController!.animateTo(1);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowCompression: true,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (videoContext) {
          return TrimmerView(file, (path) {
            print('PATH: $path');

            Navigator.pop(videoContext);

            Navigator.pushNamed(context, '/create_post',
                arguments: CreatePostArguments(path, true));
            Navigator.pushNamed(context, '/create_post',
                arguments: CreatePostArguments(path, true));
          });
        }),
      );
    }
  }

  //Nearby:

  List<SocialPost?>? nearbySocialPosts = [];
  int nearbyPage = 0;

  void _refreshNearby() {
    if (_isFirstView) return;

    final NearbySocialCubit socialCubit =
        BlocProvider.of<NearbySocialCubit>(context);

    if ((socialCubit.state is SocialLoadedState ||
            socialCubit.state is SocialErrorState) &&
        !_isFirstView) {
      nearbyPage = 0;
      socialCubit.getSocialPosts(nearbyPage);
    }
  }

  void _loadMoreNearby(SocialState socialState) {
    if (_isFirstView ||
        nearbySocialPosts!.length == 0 ||
        socialState is SocialLoadingState) {
      _nearbyRefreshController.loadComplete();
      return;
    }

    final NearbySocialCubit socialCubit =
        BlocProvider.of<NearbySocialCubit>(context);

    nearbyPage++;
    socialCubit.getSocialPosts(nearbyPage);
  }

  Widget _nearbySocialPostList() {
    return NotificationListener<ScrollNotification>(
      onNotification: getScrollNotificationListener(_nearbyRefreshController)
          as bool Function(ScrollNotification)?,
      child: BlocConsumer<NearbySocialCubit, SocialState>(
        listener: getBlocListener(_nearbyRefreshController) as void Function(
            BuildContext, SocialState),
        builder: (context, socialState) {
          bool? hasReachedMax = false;

          if (socialState is SocialLoadedState) {
            nearbySocialPosts = socialState.socialPosts;
            hasReachedMax = socialState.hasReachedMax;
          }

          return SocialPostList(
            (socialState is SocialLoadedState)
                ? socialState.socialPosts
                : nearbySocialPosts,
            hasReachedMax,
            _nearbyRefreshController,
            _refreshNearby,
            () => _loadMoreNearby(socialState),
          );
        },
      ),
    );
  }

  //Following:

  List<SocialPost?>? followingSocialPosts = [];
  int followingPage = 0;

  void _loadMoreFollowing(SocialState socialState) {
    if (_isFirstView ||
        followingSocialPosts!.length == 0 ||
        socialState is SocialLoadingState) {
      _followingRefreshController.loadComplete();
      return;
    }

    final FollowingSocialCubit socialCubit =
        BlocProvider.of<FollowingSocialCubit>(context);

    followingPage++;
    socialCubit.getSocialPosts(followingPage);
  }

  void _refreshFollowing() {
    if (_isFirstView) return;

    final FollowingSocialCubit socialCubit =
        BlocProvider.of<FollowingSocialCubit>(context);

    if ((socialCubit.state is SocialLoadedState ||
            socialCubit.state is SocialErrorState) &&
        !_isFirstView) {
      followingPage = 0;
      socialCubit.getSocialPosts(followingPage);
    }
  }

  Widget _followingSocialPostList() {
    return NotificationListener<ScrollNotification>(
      onNotification: getScrollNotificationListener(_followingRefreshController)
          as bool Function(ScrollNotification)?,
      child: BlocConsumer<FollowingSocialCubit, SocialState>(
        listener: getBlocListener(_followingRefreshController) as void Function(
            BuildContext, SocialState),
        builder: (context, socialState) {
          bool? hasReachedMax = false;

          if (socialState is SocialLoadedState) {
            followingSocialPosts = socialState.socialPosts;
            hasReachedMax = socialState.hasReachedMax;
          }

          return SmartRefresher(
            controller: _followingRefreshController,
            header: CustomMaterialClassicHeader(),
            footer: ClassicFooter(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
              noDataText: "You've reached the end of the line",
              failedText: "Something Went Wrong",
            ),
            onLoading: () => _loadMoreFollowing(socialState),
            onRefresh: _refreshFollowing,
            enablePullUp: true,
            enablePullDown: true,
            child: _followingScrollView(socialState),
          );
        },
      ),
    );
  }

  Widget _followingScrollView(SocialState socialState) {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                            ? socialState.socialPosts![index]!.postID!
                            : followingSocialPosts![index]!.postID!),
                        socialPost: (socialState is SocialLoadedState)
                            ? socialState.socialPosts![index]
                            : followingSocialPosts![index],
                        showClose: false));
              },
              childCount: (socialState is SocialLoadedState)
                  ? socialState.socialPosts!.length
                  : followingSocialPosts!.length,
            ),
          ),
        )
      ],
    );
  }

  //Trending:

  List<SocialPost?>? trendingSocialPosts = [];
  int trendingPage = 0;

  void _loadMoreTrending(SocialState socialState) {
    if (_isFirstView ||
        trendingSocialPosts!.length == 0 ||
        socialState is SocialLoadingState) {
      _trendingRefreshController.loadComplete();
      return;
    }

    final TrendingSocialCubit socialCubit =
        BlocProvider.of<TrendingSocialCubit>(context);

    trendingPage++;
    socialCubit.getSocialPosts(trendingPage);
  }

  void _refreshTrending() {
    if (_isFirstView) return;

    final TrendingSocialCubit socialCubit =
        BlocProvider.of<TrendingSocialCubit>(context);

    if ((socialCubit.state is SocialLoadedState ||
            socialCubit.state is SocialErrorState) &&
        !_isFirstView) {
      trendingPage = 0;
      socialCubit.getSocialPosts(trendingPage);
    }
  }

  Widget _trendingSocialPostList() {
    return NotificationListener<ScrollNotification>(
      onNotification: getScrollNotificationListener(_trendingRefreshController)
          as bool Function(ScrollNotification)?,
      child: BlocConsumer<TrendingSocialCubit, SocialState>(
        listener: getBlocListener(_trendingRefreshController) as void Function(
            BuildContext, SocialState),
        builder: (context, socialState) {
          bool? hasReachedMax = false;

          if (socialState is SocialLoadedState) {
            trendingSocialPosts = socialState.socialPosts;
            hasReachedMax = socialState.hasReachedMax;
            _trendingRefreshController.refreshCompleted();
          }

          if (hasReachedMax!) _trendingRefreshController.loadNoData();

          return SmartRefresher(
            controller: _trendingRefreshController,
            header: CustomMaterialClassicHeader(),
            footer: ClassicFooter(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
              noDataText: "You've reached the end of the line",
              failedText: "Something Went Wrong",
            ),
            onLoading: () => _loadMoreTrending(socialState),
            onRefresh: _refreshTrending,
            enablePullUp: true,
            enablePullDown: true,
            child: _trendingScrollView(socialState),
          );
        },
      ),
    );
  }

  Widget _trendingScrollView(SocialState socialState) {
    final List<SocialPost?> list = (socialState is SocialLoadedState)
        ? socialState.socialPosts!
        : trendingSocialPosts!;

    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = list[index]!;

                return Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SocialItem(
                      key: Key(item.postID!),
                      socialPost: item,
                      showClose: false),
                );
              },
              childCount: list.length,
            ),
          ),
        )
      ],
    );
  }
}
