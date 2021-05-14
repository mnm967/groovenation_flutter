import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentItem extends StatefulWidget {
  final SocialComment socialComment;
  PostCommentItem(this.socialComment);

  @override
  _PostCommentItemState createState() => _PostCommentItemState(socialComment);
}

class _PostCommentItemState extends State<PostCommentItem> {
  bool currentMaxLines = false;
  final SocialComment socialComment;
  _PostCommentItemState(this.socialComment);

  @override
  void initState() {
    super.initState();
    currentMaxLines = false;
  }

  _openSocialPerson(SocialPerson person) {
    Navigator.pushNamed(context, '/profile_page', arguments: person);
  }

  _likeComment() {
    //TODO Like Comment
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: () {
          setState(() {
            currentMaxLines = !currentMaxLines;
          });
        },
        padding: EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: SizedBox(
                      height: 38,
                      width: 38,
                      child: CircleAvatar(
                        backgroundColor: Colors.purple.withOpacity(0.5),
                        backgroundImage: OptimizedCacheImageProvider(
                            socialComment.person.personProfilePicURL),
                        child: FlatButton(
                            onPressed: () {
                              _openSocialPerson(socialComment.person);
                            },
                            child: Container()),
                      ))),
              Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: RichText(
                              maxLines: currentMaxLines ? 10000000 : 3,
                              overflow: TextOverflow.ellipsis,
                              text: new TextSpan(
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'LatoLight'),
                                children: <TextSpan>[
                                  new TextSpan(
                                      text: socialComment.person.personUsername,
                                      style: new TextStyle(
                                          fontFamily: 'LatoBlack')),
                                  new TextSpan(
                                      text: '\t${socialComment.comment}'),
                                ],
                              ),
                            )),
                        Padding(
                            padding:
                                EdgeInsets.only(left: 16, right: 8, top: 3),
                            child: Text(
                              socialComment.likesAmount == 1
                                  ? "${timeago.format(socialComment.postTime)} · ${socialComment.likesAmount} like"
                                  : "${timeago.format(socialComment.postTime)} · ${socialComment.likesAmount} likes",
                              style: new TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                  fontFamily: 'Lato'),
                            )),
                      ],
                    )),
              ),
              IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    socialComment.hasUserLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    _likeComment();
                  })
            ]));
  }
}
