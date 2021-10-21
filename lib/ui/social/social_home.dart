import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';
import 'package:groovenation_flutter/util/create_post_arguments.dart';
import 'package:groovenation_flutter/widgets/expandable_fab.dart';
import 'package:groovenation_flutter/widgets/filter/filter_widget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_trimmer/video_trimmer.dart';

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
  bool _isFirstView = true;

  final picker = ImagePicker();

  Future<void> _chooseSocialImage(bool isCamera) async {
    final pickedFile = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedFile == null) return;

    File croppedFile = await ImageCropper.cropImage(
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
        ));

    String imgPath = croppedFile.path;

    print("Before size: "+(File(imgPath).lengthSync().toString()));

    if (croppedFile.lengthSync() > 2000000) {
      imgPath = (await _compressAndGetFile(croppedFile,
              "${croppedFile.parent.path}/compressed-${croppedFile.path.split('/').last}"))
          .path;
    }

    print("After size: "+(File(imgPath).lengthSync().toString()));

    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => FilterWidget(imageFilePath: imgPath)));

    // Navigator.pushNamed(context, '/create_post',
    //     arguments: CreatePostArguments(imgPath, false));
  }

  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
    );

    return result;
  }

  runBuild() {
    if (_isFirstView) {
      print("Running Build: SocialHome");

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

      setState(() {
        _isFirstView = false;
      });

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
  }

  final _nearbyRefreshController = RefreshController(initialRefresh: true);
  final _trendingRefreshController = RefreshController(initialRefresh: true);
  final _followingRefreshController = RefreshController(initialRefresh: true);

  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  TabController _tabController;

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

  openSearchPage() {
    Navigator.pushNamed(context, '/search');
  }

  Column topAppBar() => Column(children: [
        Row(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
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
          )),
          Expanded(
            flex: 0,
            child: FlatButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pushNamed(context, '/conversations');
                },
                child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white.withOpacity(0.2)),
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.send,
                          size: 28,
                          color: Colors.white.withOpacity(0.5),
                        )))),
          ),
        ]),
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
        )
      ]);

  List<SocialPost> nearbySocialPosts = [];
  List<SocialPost> followingSocialPosts = [];
  List<SocialPost> trendingSocialPosts = [];

  int nearbyPage = 0;
  int followingPage = 0;
  int trendingPage = 0;

  Function getBlocListener(RefreshController refreshController) {
    return (context, socialState) {
      if (socialState is SocialLoadedState) {
        refreshController.refreshCompleted();

        if (socialState.hasReachedMax)
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
                _tabController.animateTo(1);
                _chooseSocialImage(true);
              },
            ),
            ActionButton(
              icon: const Icon(FontAwesomeIcons.images),
              onPressed: () {
                _tabController.animateTo(1);
                _chooseSocialImage(false);
              },
            ),
            ActionButton(
              icon: const Icon(FontAwesomeIcons.video),
              onPressed: () async {
                _tabController.animateTo(1);
                FilePickerResult result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                  allowCompression: false,
                );
                if (result != null) {
                  File file = File(result.files.single.path);
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
              },
            ),
          ],
        ),
        body: SafeArea(
            child: DefaultTabController(
                length: 3,
                initialIndex: 1,
                child: Column(
                  children: [
                    topAppBar(),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [
                        NotificationListener<ScrollNotification>(
                            onNotification: getScrollNotificationListener(
                                _nearbyRefreshController),
                            child: BlocConsumer<NearbySocialCubit, SocialState>(
                                listener:
                                    getBlocListener(_nearbyRefreshController),
                                builder: (context, socialState) {
                                  bool hasReachedMax = false;

                                  if (socialState is SocialLoadedState) {
                                    nearbySocialPosts = socialState.socialPosts;

                                    // if (nearbyPage == 0)
                                    //   nearbySocialPosts = socialState.socialPosts;
                                    // else {
                                    //   nearbySocialPosts
                                    //       .addAll(socialState.socialPosts);
                                    // }
                                    hasReachedMax = socialState.hasReachedMax;
                                  }

                                  return SocialPostList(
                                      (socialState is SocialLoadedState)
                                          ? socialState.socialPosts
                                          : nearbySocialPosts,
                                      hasReachedMax,
                                      _nearbyRefreshController, () {
                                    if (_isFirstView) return;

                                    final NearbySocialCubit socialCubit =
                                        BlocProvider.of<NearbySocialCubit>(
                                            context);

                                    if ((socialCubit.state
                                                is SocialLoadedState ||
                                            socialCubit.state
                                                is SocialErrorState) &&
                                        !_isFirstView) {
                                      nearbyPage = 0;
                                      socialCubit.getSocialPosts(nearbyPage);
                                    }
                                  }, () {
                                    if (_isFirstView ||
                                        nearbySocialPosts.length == 0 ||
                                        socialState is SocialLoadingState) {
                                      _nearbyRefreshController.loadComplete();
                                      return;
                                    }

                                    final NearbySocialCubit socialCubit =
                                        BlocProvider.of<NearbySocialCubit>(
                                            context);

                                    nearbyPage++;
                                    socialCubit.getSocialPosts(nearbyPage);
                                  });
                                })),
                        NotificationListener<ScrollNotification>(
                          onNotification: getScrollNotificationListener(
                              _followingRefreshController),
                          child: BlocConsumer<FollowingSocialCubit,
                                  SocialState>(
                              listener:
                                  getBlocListener(_followingRefreshController),
                              builder: (context, socialState) {
                                bool hasReachedMax = false;

                                if (socialState is SocialLoadedState) {
                                  followingSocialPosts =
                                      socialState.socialPosts;
                                  hasReachedMax = socialState.hasReachedMax;
                                  // if (followingPage == 0)
                                  //   followingSocialPosts = socialState.socialPosts;
                                  // else {
                                  //   followingSocialPosts
                                  //       .addAll(socialState.socialPosts);
                                  // }
                                }

                                return SmartRefresher(
                                    controller: _followingRefreshController,
                                    header: WaterDropMaterialHeader(),
                                    footer: ClassicFooter(
                                      textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 16,
                                          fontFamily: 'Lato'),
                                      noDataText:
                                          "You've reached the end of the line",
                                      failedText: "Something Went Wrong",
                                    ),
                                    onLoading: () {
                                      if (_isFirstView ||
                                          followingSocialPosts.length == 0 ||
                                          socialState is SocialLoadingState) {
                                        _followingRefreshController
                                            .loadComplete();
                                        return;
                                      }

                                      final FollowingSocialCubit socialCubit =
                                          BlocProvider.of<FollowingSocialCubit>(
                                              context);

                                      followingPage++;
                                      socialCubit.getSocialPosts(followingPage);
                                    },
                                    onRefresh: () {
                                      if (_isFirstView) return;

                                      final FollowingSocialCubit socialCubit =
                                          BlocProvider.of<FollowingSocialCubit>(
                                              context);

                                      if ((socialCubit.state
                                                  is SocialLoadedState ||
                                              socialCubit.state
                                                  is SocialErrorState) &&
                                          !_isFirstView) {
                                        followingPage = 0;
                                        socialCubit
                                            .getSocialPosts(followingPage);
                                      }
                                    },
                                    enablePullUp: true,
                                    enablePullDown: true,
                                    child: CustomScrollView(
                                      physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                      slivers: [
                                        SliverPadding(
                                          padding: EdgeInsets.only(top: 24),
                                          sliver: SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              return Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                                  child: SocialItem(
                                                      key: Key((socialState
                                                              is SocialLoadedState)
                                                          ? socialState
                                                              .socialPosts[
                                                                  index]
                                                              .postID
                                                          : followingSocialPosts[index]
                                                              .postID),
                                                      socialPost: (socialState
                                                              is SocialLoadedState)
                                                          ? socialState
                                                                  .socialPosts[
                                                              index]
                                                          : followingSocialPosts[
                                                              index],
                                                      showClose: false));
                                            },
                                            childCount: (socialState
                                                    is SocialLoadedState)
                                                ? socialState.socialPosts.length
                                                : followingSocialPosts.length,
                                          )),
                                        )
                                      ],
                                    ));

                                // return SocialPostList(followingSocialPosts,
                                //     hasReachedMax, _followingRefreshController, () {
                                //   final FollowingSocialCubit socialCubit =
                                //       BlocProvider.of<FollowingSocialCubit>(
                                //           context);

                                //   if ((socialCubit.state is SocialLoadedState ||
                                //           socialCubit.state is SocialErrorState) &&
                                //       !_isFirstView) {
                                //     followingPage = 0;
                                //     socialCubit.getSocialPosts(followingPage);
                                //   }
                                // }, () {
                                //   if (_isFirstView ||
                                //       followingSocialPosts.length == 0 ||
                                //       socialState is SocialLoadingState) {
                                //     _followingRefreshController.loadComplete();
                                //     return;
                                //   }

                                //   final FollowingSocialCubit socialCubit =
                                //       BlocProvider.of<FollowingSocialCubit>(
                                //           context);

                                //   followingPage++;
                                //   socialCubit.getSocialPosts(followingPage);
                                // });
                              }),
                        ),
                        NotificationListener<ScrollNotification>(
                          onNotification: getScrollNotificationListener(
                              _trendingRefreshController),
                          child: BlocConsumer<TrendingSocialCubit, SocialState>(
                              listener:
                                  getBlocListener(_trendingRefreshController),
                              builder: (context, socialState) {
                                bool hasReachedMax = false;

                                if (socialState is SocialLoadedState) {
                                  trendingSocialPosts = socialState.socialPosts;
                                  // if (trendingPage == 0)
                                  //   trendingSocialPosts = socialState.socialPosts;
                                  // else {
                                  //   trendingSocialPosts
                                  //       .addAll(socialState.socialPosts);
                                  // }
                                  hasReachedMax = socialState.hasReachedMax;
                                  _trendingRefreshController.refreshCompleted();
                                }

                                if (hasReachedMax)
                                  _trendingRefreshController.loadNoData();

                                return SmartRefresher(
                                    controller: _trendingRefreshController,
                                    header: WaterDropMaterialHeader(),
                                    footer: ClassicFooter(
                                      textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 16,
                                          fontFamily: 'Lato'),
                                      noDataText:
                                          "You've reached the end of the line",
                                      failedText: "Something Went Wrong",
                                    ),
                                    onLoading: () {
                                      if (_isFirstView ||
                                          trendingSocialPosts.length == 0 ||
                                          socialState is SocialLoadingState) {
                                        _trendingRefreshController
                                            .loadComplete();
                                        return;
                                      }

                                      final TrendingSocialCubit socialCubit =
                                          BlocProvider.of<TrendingSocialCubit>(
                                              context);

                                      trendingPage++;
                                      socialCubit.getSocialPosts(trendingPage);
                                    },
                                    onRefresh: () {
                                      if (_isFirstView) return;

                                      final TrendingSocialCubit socialCubit =
                                          BlocProvider.of<TrendingSocialCubit>(
                                              context);

                                      if ((socialCubit.state
                                                  is SocialLoadedState ||
                                              socialCubit.state
                                                  is SocialErrorState) &&
                                          !_isFirstView) {
                                        trendingPage = 0;
                                        socialCubit
                                            .getSocialPosts(trendingPage);
                                      }
                                    },
                                    enablePullUp: true,
                                    enablePullDown: true,
                                    child: CustomScrollView(
                                      physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                      slivers: [
                                        SliverPadding(
                                          padding: EdgeInsets.only(top: 24),
                                          sliver: SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              return Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                                  child: SocialItem(
                                                      key: Key((socialState
                                                              is SocialLoadedState)
                                                          ? socialState
                                                              .socialPosts[
                                                                  index]
                                                              .postID
                                                          : trendingSocialPosts[index]
                                                              .postID),
                                                      socialPost: (socialState
                                                              is SocialLoadedState)
                                                          ? socialState
                                                                  .socialPosts[
                                                              index]
                                                          : trendingSocialPosts[
                                                              index],
                                                      showClose: false));
                                            },
                                            childCount: (socialState
                                                    is SocialLoadedState)
                                                ? socialState.socialPosts.length
                                                : trendingSocialPosts.length,
                                          )),
                                        )
                                      ],
                                    ));

                                // return SocialPostList(trendingSocialPosts,
                                //     hasReachedMax, _trendingRefreshController, () {
                                //   final TrendingSocialCubit socialCubit =
                                //       BlocProvider.of<TrendingSocialCubit>(context);

                                //   if ((socialCubit.state is SocialLoadedState ||
                                //           socialCubit.state is SocialErrorState) &&
                                //       !_isFirstView) {
                                //     trendingPage = 0;
                                //     socialCubit.getSocialPosts(trendingPage);
                                //   }
                                // }, () {
                                //   if (_isFirstView ||
                                //       trendingSocialPosts.length == 0 ||
                                //       socialState is SocialLoadingState) {
                                //     _trendingRefreshController.loadComplete();
                                //     return;
                                //   }

                                //   final TrendingSocialCubit socialCubit =
                                //       BlocProvider.of<TrendingSocialCubit>(context);

                                //   trendingPage++;
                                //   socialCubit.getSocialPosts(trendingPage);
                                // });
                              }),
                        ),
                      ]),
                    )
                  ],
                ))));
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
          noDataText: "You've reached the end of the line",
          failedText: "Something Went Wrong",
        ),
        onLoading: () {
          onLoading();
        },
        onRefresh: () {
          onRefresh();
        },
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
                          key: Key(socialPosts[index].postID),
                          socialPost: socialPosts[index],
                          showClose: false));
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

class TrimmerView extends StatefulWidget {
  final File file;
  final Function _onVideoPicked;

  TrimmerView(this.file, this._onVideoPicked);

  @override
  _TrimmerViewState createState() => _TrimmerViewState(_onVideoPicked);
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();
  final Function onVideoPicked;

  _TrimmerViewState(this.onVideoPicked);

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await _trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }

  Future<String> _compressVideo(String videoPath) async {
    MediaInfo mediaInfo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true, // It's false by default
    );

    return mediaInfo.path;
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Video"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            if (File(outputPath).lengthSync() > 50000000)
                              _compressVideo(outputPath).then((newPath) {
                                onVideoPicked(newPath);
                                Navigator.pop(context);
                              });
                            else {
                              onVideoPicked(outputPath);
                              Navigator.pop(context);
                            }
                          });
                        },
                  child: Text("DONE"),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimEditor(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(seconds: 60),
                    fit: BoxFit.contain,
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
