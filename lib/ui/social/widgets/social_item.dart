import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/integers.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_post_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_state.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/widgets/comment_item.dart';
import 'package:groovenation_flutter/ui/social/dialogs/comments_dialog.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:groovenation_flutter/widgets/report_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SocialItem extends StatefulWidget {
  final SocialPost? socialPost;
  final bool showClose;
  final bool? removeElevation;

  SocialItem(
      {required this.socialPost,
      required this.showClose,
      required Key key,
      this.removeElevation})
      : super(key: key);

  @override
  _SocialItemState createState() => _SocialItemState();
}

class _SocialItemState extends State<SocialItem> {
  SocialPost? socialPost;
  bool showClose = false;
  VideoPlayerController? _controller;
  bool isVideoPlaying = false;
  bool? removeElevation = false;

  final FlareControls flareControls = FlareControls();

  void _initializeVideoController() {
    _controller = VideoPlayerController.network(socialPost!.mediaURL!)
      ..initialize().then(
        (_) {
          setState(() {});

          _controller!.setVolume(0.0);
          if (showClose) _controller!.play();
        },
      );

    _controller!.setLooping(true);
  }

  @override
  void initState() {
    super.initState();
    socialPost = widget.socialPost;
    showClose = widget.showClose;
    removeElevation =
        widget.removeElevation == null ? false : widget.removeElevation;

    if (socialPost!.postType == SOCIAL_POST_TYPE_VIDEO)
      _initializeVideoController();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  void _blocListener(context, socialState) {
    if (socialState is SocialPostLikeUpdatingState) {
      if (socialState.post.postID == socialPost!.postID) {
        setState(
          () {
            socialPost = socialState.post;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocialPostCubit, SocialState>(
      listener: _blocListener,
      child: _socialItem(context),
    );
  }

  void _likePost(bool canUnlike) {
    if ((socialPost!.hasUserLiked! && canUnlike) ||
        !socialPost!.hasUserLiked!) {
      final SocialPostCubit socialPostCubit =
          BlocProvider.of<SocialPostCubit>(context);
      socialPostCubit.changeLikePost(context, socialPost!);
    }
  }

  void _sharePost() {
    Navigator.pushNamed(
      context,
      '/social_people_search',
      arguments: (SocialPerson sperson) async {
        final ConversationsCubit conversationsCubit =
            BlocProvider.of<ConversationsCubit>(context);

        Conversation? conversation =
            await conversationsCubit.getPersonConversation(sperson.personID);

        SocialPostMessage message = SocialPostMessage(
            null,
            conversation == null ? null : conversation.conversationID,
            DateTime.now(),
            SocialPerson(
                sharedPrefs.userId,
                sharedPrefs.username,
                sharedPrefs.profilePicUrl,
                sharedPrefs.coverPicUrl,
                false,
                false,
                sharedPrefs.userFollowersCount),
            socialPost,
            sperson.personID);

        if (conversation == null) {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: ChatPageArguments(
                Conversation(null, sperson, 0, null), message),
          );
        } else {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: ChatPageArguments(conversation, message),
          );
        }
      },
    );
  }

  void _reportPost() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ReportDialog(null, socialPost);
        });
  }

  void _openSocialPerson(SocialPerson socialPerson) {
    if (socialPerson.personID == sharedPrefs.userId) return;
    Navigator.pushNamed(context, '/profile_page', arguments: socialPerson);
  }

  void _playVideo() {
    setState(() {
      isVideoPlaying = true;
    });
    _controller!.play();
  }

  void _pauseVideo() {
    setState(() {
      isVideoPlaying = false;
    });
    _controller!.pause();
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profilePic(),
          _headerText(),
          _popupMenu(),
        ],
      ),
    );
  }

  Widget _headerText() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 16, top: 0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              socialPost!.person.personUsername!,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'LatoBold', fontSize: 18, color: Colors.white),
            ),
            socialPost!.clubName != null
                ? Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.local_bar,
                            size: 20, color: Colors.white.withOpacity(0.4)),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            socialPost!.clubName!,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.4)),
                          ),
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.zero,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _profilePic() {
    return SizedBox(
      height: 64,
      width: 64,
      child: CircleAvatar(
        backgroundColor: Colors.purple.withOpacity(0.5),
        backgroundImage:
            CachedNetworkImageProvider(socialPost!.person.personProfilePicURL!),
        child: FlatButton(
            onPressed: () => _openSocialPerson(socialPost!.person),
            child: Container()),
      ),
    );
  }

  Widget _popupMenu() {
    return Align(
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
            icon: Icon(Icons.more_vert, color: Colors.white, size: 28),
            itemBuilder: (BuildContext context) {
              return {'Report'}.map((String choice) {
                return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice,
                        style: TextStyle(color: Colors.deepPurple)));
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialItem(BuildContext context) {
    return Wrap(
      children: [
        Container(
          child: Card(
            color: Colors.deepPurple,
            elevation: removeElevation! ? 0 : 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              child: Column(
                children: [
                  _header(),
                  _content(),
                  _optionButtonsRow(),
                  _likesCount(),
                  _caption(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _caption() {
    return socialPost!.caption == null
        ? Padding(padding: EdgeInsets.only(top: 8))
        : CommentItem(socialPost!.person, socialPost!.caption);
  }

  Widget _likesCount() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Text(
          (socialPost!.likesAmount == 1
                  ? "${socialPost!.likesAmount} like"
                  : "${socialPost!.likesAmount} likes") +
              " · " +
              (socialPost!.commentsAmount == 1
                  ? "${socialPost!.commentsAmount} comment"
                  : "${socialPost!.commentsAmount} comments"),
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
              fontFamily: 'Lato'),
        ),
      ),
    );
  }

  Widget _content() {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 0),
      child: AspectRatio(
        aspectRatio: socialPost!.postType == SOCIAL_POST_TYPE_IMAGE ? 1.0 : 0.9,
        child: Stack(
          children: [
            _mediaView(),
            _playButton(),
          ],
        ),
      ),
    );
  }

  Widget _playButton() {
    return Visibility(
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
        ),
      ),
    );
  }

  Widget _mediaView() {
    return GestureDetector(
      onDoubleTap: () {
        flareControls.play('like');
        _likePost(false);
      },
      child: Stack(
        children: [
          socialPost!.postType == SOCIAL_POST_TYPE_IMAGE
              ? CroppedCacheImage(url: socialPost!.mediaURL)
              : _autoplayVideoView(),
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
      ),
    );
  }

  Widget _autoplayVideoView() {
    return VisibilityDetector(
      key: Key('social-item-' + socialPost!.postID.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (_controller == null) return;

        var visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visiblePercentage > 75) {
          if (!isVideoPlaying) _playVideo();
        } else {
          if (isVideoPlaying) _pauseVideo();
        }
      },
      child: Container(
        color: socialPost!.postType == SOCIAL_POST_TYPE_IMAGE
            ? Colors.deepPurple
            : Colors.black,
        child: _controller!.value.isInitialized
            ? _videoLoadingIndicator()
            : _videoThumbnail(),
      ),
    );
  }

  Widget _videoLoadingIndicator() {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(
              _controller!,
            ),
          ),
        ),
        (_controller!.value.isBuffering || !_controller!.value.isInitialized)
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                  strokeWidth: 2,
                ),
              )
            : Center(),
      ],
    );
  }

  Widget _videoThumbnail() {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 0.9,
            child: CroppedCacheImage(
              url: socialPost!.mediaURL!
                  .replaceAll(".mp4", ".png")
                  .replaceAll("/posts/", "/thumbnails/"),
            ),
          ),
        ),
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.7)),
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }

  Widget _optionButtonsRow() {
    return Row(
      children: [
        _likeButton(),
        _commentButton(),
        _shareButton(),
      ],
    );
  }

  Widget _shareButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
      child: GestureDetector(
        child: Icon(
          FontAwesomeIcons.shareSquare,
          size: 28,
          color: Colors.white,
        ),
        onTap: () {
          _sharePost();
        },
      ),
    );
  }

  Widget _likeButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
      child: GestureDetector(
        child: Icon(
          socialPost!.hasUserLiked!
              ? FontAwesomeIcons.solidHeart
              : FontAwesomeIcons.heart,
          size: 28,
          color: Colors.white,
        ),
        onTap: () {
          if (!socialPost!.hasUserLiked!) flareControls.play('like');
          _likePost(true);
        },
      ),
    );
  }

  Widget _commentButton() {
    return Padding(
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
                position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(
                    CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
