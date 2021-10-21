import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:video_player/video_player.dart';

class CreatePostPage extends StatefulWidget {
  final String mediaPath;
  final bool isVideo;

  CreatePostPage(this.mediaPath, this.isVideo);

  @override
  _CreatePostPageState createState() =>
      _CreatePostPageState(mediaPath, isVideo);
}

class _CreatePostPageState extends State<CreatePostPage> {
  VideoPlayerController _controller;

  final String mediaPath;
  final bool isVideo;
  bool isVideoThumbnailVisible = true;
  bool isVideoPlaying = false;

  String selectedClubID;
  String selectedClubName;
  TextEditingController captionTextEditingController = TextEditingController();

  _CreatePostPageState(this.mediaPath, this.isVideo);

  @override
  void initState() {
    super.initState();

    if (isVideo) {
      _controller = VideoPlayerController.file(File(mediaPath))
        ..initialize().then((_) {
          setState(() {});
        });

      _controller.setLooping(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (isVideo) _controller.dispose();
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _isLoadingVisible = false;
  Future<void> _showLoadingDialog(BuildContext context) async {
    _isLoadingVisible = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(_keyLoader, "Please Wait...");
        });
  }

  _hideLoadingDialog() {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }
  }

  Future<void> _showAlertDialog(
      String title, String desc, Function onButtonClick) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontFamily: 'Lato'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(desc, style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay"),
              onPressed: () {
                onButtonClick();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
        child: Stack(children: [
      CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: BlocListener<SocialPostCubit, SocialState>(
                listener: (context, socialUploadState) {
                  if (socialUploadState is SocialPostUploadLoadingState) {
                    _showLoadingDialog(context);
                  } else if (socialUploadState
                      is SocialPostUploadSuccessState) {
                    _hideLoadingDialog();
                    _showAlertDialog(
                        SOCIAL_POST_SUCCESS_TITLE, SOCIAL_POST_SUCCESS_DESC,
                        () {
                      Navigator.pop(context);
                    });
                  } else if (socialUploadState is SocialPostUploadErrorState) {
                    _hideLoadingDialog();
                    _showAlertDialog(
                        SOCIAL_POST_ERROR_TITLE, NETWORK_ERROR_PROMPT, () {});
                  }
                },
                child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 16, top: 8),
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(900)),
                                  child: FlatButton(
                                    padding: EdgeInsets.only(left: 0),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 36, top: 16, bottom: 16),
                                child: Text(
                                  "Create Post",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontFamily: 'LatoBold'),
                                )),
                          ],
                        ),
                        isVideo
                            ? Padding(padding: EdgeInsets.zero)
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  color: Colors.deepPurple,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: Image.file(File(mediaPath)),
                                ),
                              ),
                        isVideo
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: AspectRatio(
                                    aspectRatio: 0.8,
                                    child: Card(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        elevation: 10,
                                        color: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        child: Center(
                                            child: _controller
                                                    .value.isInitialized
                                                ? Stack(children: [
                                                    Center(
                                                        child: AspectRatio(
                                                      aspectRatio: _controller
                                                          .value.aspectRatio,
                                                      child: VideoPlayer(
                                                        _controller,
                                                      ),
                                                    )),
                                                    isVideoPlaying
                                                        ? TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero),
                                                            onPressed: () {
                                                              setState(() {
                                                                isVideoPlaying =
                                                                    false;
                                                              });
                                                              _controller
                                                                  .pause();
                                                            },
                                                            child: AspectRatio(
                                                                aspectRatio:
                                                                    0.8,
                                                                child:
                                                                    Container()))
                                                        : TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero),
                                                            onPressed: () {
                                                              if (isVideoThumbnailVisible) {
                                                                setState(() {
                                                                  isVideoThumbnailVisible =
                                                                      false;
                                                                  isVideoPlaying =
                                                                      true;
                                                                });

                                                                _controller
                                                                    .play();
                                                              } else {
                                                                setState(() {
                                                                  isVideoPlaying =
                                                                      true;
                                                                });
                                                                _controller
                                                                    .play();
                                                              }
                                                            },
                                                            child: AspectRatio(
                                                              aspectRatio: 0.8,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .play_circle_fill,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 96,
                                                                ),
                                                              ),
                                                            )),
                                                  ])
                                                : Container()))))
                            : Padding(padding: EdgeInsets.zero),
                        Padding(
                          padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white.withOpacity(0.2)),
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              autofocus: false,
                              maxLines: null,
                              controller: captionTextEditingController,
                              cursorColor: Colors.white.withOpacity(0.7),
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  color: Colors.white,
                                  fontSize: 20),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  hintText: "Add a Caption (Optional)",
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3))),
                            ),
                          ),
                        ),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 24, left: 16, right: 16),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              onPressed: () {
                                Navigator.pushNamed(context, '/club_search',
                                    arguments: (String id, String name) {
                                  setState(() {
                                    selectedClubID = id;
                                    selectedClubName = name;
                                  });
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white.withOpacity(0.2)),
                                child: Center(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(right: 16),
                                            child: Icon(
                                              FontAwesomeIcons.mapMarkerAlt,
                                              color: selectedClubName != null
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.4),
                                              size: 20,
                                            )),
                                        Text(
                                          selectedClubName != null
                                              ? selectedClubName
                                              : "Click here to tag a Club",
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              color: selectedClubName != null
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.4),
                                              fontSize: 20),
                                        )
                                      ]),
                                ),
                              ),
                            )),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 12, right: 12),
                          child: Container(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 16),
                            height: 88,
                            child: Card(
                              elevation: 0,
                              color: Colors.deepPurple,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              semanticContainer: true,
                              child: FlatButton(
                                  onPressed: () {
                                    final SocialPostCubit
                                        socialPostUploadCubit =
                                        BlocProvider.of<SocialPostCubit>(
                                            context);

                                    socialPostUploadCubit.uploadPost(
                                      context,
                                        mediaPath,
                                        captionTextEditingController.text,
                                        selectedClubID,
                                        isVideo);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Center(
                                        child: Text(
                                      "Upload Post",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    )),
                                  )),
                            ),
                          )),
                        ),
                      ],
                    ))),
          )
        ],
      ),
    ]));
  }
}
