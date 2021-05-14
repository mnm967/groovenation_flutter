import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/comment_item.dart';
import 'package:groovenation_flutter/ui/social/comments_dialog.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SocialItem extends StatefulWidget {
  final SocialPost socialPost;
  final bool showClose;
  SocialItem({@required this.socialPost, @required this.showClose});

  @override
  _SocialItemState createState() =>
      _SocialItemState(socialPost: socialPost, showClose: showClose);
}

class _SocialItemState extends State<SocialItem> {
  SocialPost socialPost;
  bool showClose = false;

  _SocialItemState({this.socialPost, this.showClose});

  final FlareControls flareControls = FlareControls();

  @override
  Widget build(BuildContext context) {
    return socialItem(context);
  }

  _likePost(bool canUnlike) {
    //TODO Like Post
  }

  _sharePost() {
    //TODO Share Post
  }

  _reportPost() {
    //TODO Report Post
  }

  _openSocialPerson(SocialPerson socialPerson) {
    //TODO Open Social Person
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
                            // backgroundImage: OptimizedCacheImageProvider(
                            //     socialPost.person.personProfilePicURL),
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
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          GestureDetector(
                              onDoubleTap: () {
                                flareControls.play('like');
                                _likePost(false);
                              },
                              child: Stack(
                                children: [
                                  CroppedCacheImage(url: socialPost.mediaURL),
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
                          FontAwesomeIcons.heart,
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
