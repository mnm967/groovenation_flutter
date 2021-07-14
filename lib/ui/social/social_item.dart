import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/integers.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/comment_item.dart';
import 'package:groovenation_flutter/ui/social/comments_dialog.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SocialItem extends StatefulWidget {
  final SocialPost socialPost;
  final bool showClose;
  SocialItem(
      {@required this.socialPost, @required this.showClose, @required Key key})
      : super(key: key);

  @override
  _SocialItemState createState() =>
      _SocialItemState(socialPost: socialPost, showClose: showClose);
}

class _SocialItemState extends State<SocialItem> {
  SocialPost socialPost;
  bool showClose = false;
  VideoPlayerController _controller;
  bool isVideoPlaying = false;

  _SocialItemState({this.socialPost, this.showClose});

  final FlareControls flareControls = FlareControls();

  @override
  void initState() {
    super.initState();

    if (socialPost.postType == SOCIAL_POST_TYPE_VIDEO) {
      _controller = VideoPlayerController.network(socialPost.mediaURL)
        ..initialize().then((_) {
          _controller.play();
          _controller.pause();
        });

      _controller.setLooping(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller.dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocialPostCubit, SocialState>(
        listener: (context, socialState) {
          if (socialState is SocialPostLikeUpdatingState) {
            if (socialState.post.postID == socialPost.postID) {
              setState(() {
                socialPost = socialState.post;
              });
            }
          }
        },
        child: socialItem(context));
  }

  _likePost(bool canUnlike) {
    if ((socialPost.hasUserLiked && canUnlike) || !socialPost.hasUserLiked) {
      final SocialPostCubit socialPostCubit =
          BlocProvider.of<SocialPostCubit>(context);
      socialPostCubit.changeLikePost(context, socialPost);
    }
  }

  _sharePost() {
    //TODO Share Post
  }

  _reportPost() {
    //TODO Report Post
  }

  _openSocialPerson(SocialPerson socialPerson) {
    Navigator.pushNamed(context, '/profile_page', arguments: socialPerson);
  }

  _playVideo() {
    setState(() {
      isVideoPlaying = true;
    });
    _controller.play();
  }

  _pauseVideo() {
    setState(() {
      isVideoPlaying = false;
    });
    _controller.pause();
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
                                socialPost.person.personProfilePicURL),
                            child: FlatButton(
                                onPressed: () {
                                  _openSocialPerson(socialPost.person);
                                  //Navigator.pushNamed(context, '/profile_page');
                                },
                                child: Container()),
                          )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(left: 16, top: 0, right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              socialPost.person.personUsername,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'LatoBold',
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            socialPost.clubName != null
                                ? Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_bar,
                                            size: 20,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                        Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Text(
                                            socialPost.clubName,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'Lato',
                                                fontSize: 16,
                                                color: Colors.white
                                                    .withOpacity(0.4)),
                                          ),
                                        )
                                      ],
                                    ))
                                : Padding(
                                    padding: EdgeInsets.zero,
                                  ),
                          ],
                        ),
                      )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (item) {
                                if (item == 'Report') {
                                  _reportPost();
                                }
                              },
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_vert,
                                  color: Colors.white, size: 28),
                              itemBuilder: (BuildContext context) {
                                return {'Report'}.map((String choice) {
                                  return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice,
                                          style: TextStyle(
                                              color: Colors.deepPurple)));
                                }).toList();
                              },
                            ),
                            Visibility(
                                visible: this.showClose,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }))
                          ],
                        ),
                      )
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 0),
                  child: AspectRatio(
                      aspectRatio: socialPost.postType == SOCIAL_POST_TYPE_IMAGE
                          ? 1.0
                          : 0.9,
                      child: Stack(
                        children: [
                          GestureDetector(
                              onDoubleTap: () {
                                flareControls.play('like');
                                _likePost(false);
                              },
                              child: Stack(
                                children: [
                                  socialPost.postType == SOCIAL_POST_TYPE_IMAGE
                                      ? CroppedCacheImage(
                                          url: socialPost.mediaURL)
                                      : VisibilityDetector(
                                          key: Key('social-item-' +
                                              socialPost.postID.toString()),
                                          onVisibilityChanged:
                                              (visibilityInfo) {
                                            if (_controller == null) return;

                                            var visiblePercentage =
                                                visibilityInfo.visibleFraction *
                                                    100;

                                            if (visiblePercentage > 75) {
                                              if (!isVideoPlaying) _playVideo();
                                            } else {
                                              if (isVideoPlaying) _pauseVideo();
                                            }

                                            debugPrint(
                                                'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
                                          },
                                          child: Container(
                                            color: socialPost.postType ==
                                                    SOCIAL_POST_TYPE_IMAGE
                                                ? Colors.deepPurple
                                                : Colors.black,
                                            child:
                                                // _controller.value.isInitialized
                                                true
                                                    ? Stack(children: [
                                                        Center(
                                                            child: AspectRatio(
                                                          aspectRatio:
                                                              _controller.value
                                                                  .aspectRatio,
                                                          child: VideoPlayer(
                                                            _controller,
                                                          ),
                                                        )),
                                                        (_controller.value
                                                                    .isBuffering ||
                                                                !_controller
                                                                    .value
                                                                    .isInitialized)
                                                            ? Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                valueColor: new AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.7)),
                                                                strokeWidth: 2,
                                                              ))
                                                            : Center()
                                                        // isVideoPlaying
                                                        //     ? TextButton(
                                                        //         style: TextButton
                                                        //             .styleFrom(
                                                        //                 padding:
                                                        //                     EdgeInsets
                                                        //                         .zero),
                                                        //         onPressed: () {
                                                        //           _pauseVideo();
                                                        //         },
                                                        //         child: AspectRatio(
                                                        //             aspectRatio:
                                                        //                 0.8,
                                                        //             child:
                                                        //                 Container()))
                                                        //     : TextButton(
                                                        //         style: TextButton
                                                        //             .styleFrom(
                                                        //                 padding:
                                                        //                     EdgeInsets
                                                        //                         .zero),
                                                        //         onPressed: () {
                                                        //           _playVideo();
                                                        //         },
                                                        //         child: AspectRatio(
                                                        //           aspectRatio: 0.8,
                                                        //           child: Center(
                                                        //             child: Icon(
                                                        //               Icons
                                                        //                   .play_circle_fill,
                                                        //               color: Colors
                                                        //                   .white
                                                        //                   .withOpacity(
                                                        //                       0.6),
                                                        //               size: 96,
                                                        //             ),
                                                        //           ),
                                                        //         )),
                                                      ])
                                                    : Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.7)),
                                                        strokeWidth: 2,
                                                      )),
                                          )),
                                  Container(
                                    child: Center(
                                      child: SizedBox(
                                        width: 128,
                                        height: 128,
                                        child: FlareActor(
                                          'assets/icons/heart.flr',
                                          controller: flareControls,
                                          animation: 'idle',
                                        ),
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
                          socialPost.hasUserLiked
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {
                          _likePost(true);
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.comment,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {
                          showGeneralDialog(
                            barrierLabel: "Barrier",
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.7),
                            transitionDuration: Duration(milliseconds: 500),
                            context: context,
                            pageBuilder: (con, __, ___) {
                              return CommentsDialog(
                                socialPost: socialPost,
                              );
                            },
                            transitionBuilder: (_, anim, __, child) {
                              return SlideTransition(
                                position: Tween(
                                        begin: Offset(0, 1), end: Offset(0, 0))
                                    .animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.elasticOut)),
                                child: child,
                              );
                            },
                          );
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.shareSquare,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {
                          _sharePost();
                        }),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    socialPost.likesAmount == 1
                        ? "${socialPost.likesAmount} like"
                        : "${socialPost.likesAmount} likes",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 18,
                        fontFamily: 'Lato'),
                  ),
                ),
              ),
              socialPost.caption == null
                  ? Padding(padding: EdgeInsets.only(top: 8))
                  : CommentItem(socialPost.person, socialPost.caption),
            ],
          )),
        ),
      )
    ]);
  }
}
