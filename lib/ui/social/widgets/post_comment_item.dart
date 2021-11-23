import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/social/social_comments_like_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentItem extends StatefulWidget {
  final SocialComment socialComment;
  PostCommentItem(Key key, this.socialComment) : super(key: key);

  @override
  _PostCommentItemState createState() => _PostCommentItemState();
}

class _PostCommentItemState extends State<PostCommentItem> {
  bool _showAllLines = false;
  late SocialComment _socialComment;

  _PostCommentItemState();

  @override
  void initState() {
    super.initState();
    _socialComment = widget.socialComment;
    _showAllLines = false;
  }

  void _openSocialPerson(SocialPerson person) {
    Navigator.pushNamed(context, '/profile_page', arguments: person);
  }

  void _likeComment() {
    if (_socialComment.commentId != null) {
      final SocialCommentsLikeCubit socialCommentsLikeCubit =
          BlocProvider.of<SocialCommentsLikeCubit>(context);
      socialCommentsLikeCubit.changeLikeComment(context, _socialComment);
    }
  }

  void _blocListener(context, socialState) {
    if (socialState is SocialCommentLikeUpdatingState) {
      if (socialState.comment.commentId == _socialComment.commentId) {
        setState(
          () {
            _socialComment = socialState.comment;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocialCommentsLikeCubit, SocialCommentsState>(
      listener: _blocListener,
      child: FlatButton(
        onPressed: () {
          setState(() {
            _showAllLines = !_showAllLines;
          });
        },
        padding: EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profilePic(),
            _postContent(),
            _likeCommentButton(),
          ],
        ),
      ),
    );
  }

  Widget _profilePic() {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 38,
        width: 38,
        child: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.5),
          backgroundImage: CachedNetworkImageProvider(
              _socialComment.person.personProfilePicURL!),
          child: FlatButton(
            onPressed: () {
              _openSocialPerson(_socialComment.person);
            },
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget _postContent() {
    return Expanded(
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _postText(),
            _postTime(),
          ],
        ),
      ),
    );
  }

  Widget _postText() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 8),
      child: RichText(
        maxLines: _showAllLines ? 10000000 : 3,
        overflow: TextOverflow.ellipsis,
        text: new TextSpan(
          style: new TextStyle(
              color: Colors.white, fontSize: 16, fontFamily: 'LatoLight'),
          children: [
            new TextSpan(
                text: _socialComment.person.personUsername,
                style: new TextStyle(fontFamily: 'LatoBlack')),
            new TextSpan(text: '\t${_socialComment.comment}'),
          ],
        ),
      ),
    );
  }

  Widget _postTime() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 8, top: 3),
      child: Text(
        _socialComment.likesAmount == 1
            ? "${timeago.format(_socialComment.postTime)} · ${_socialComment.likesAmount} like"
            : "${timeago.format(_socialComment.postTime)} · ${_socialComment.likesAmount} likes",
        style: new TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
            fontFamily: 'Lato'),
      ),
    );
  }

  Widget _likeCommentButton() {
    return Visibility(
      visible: _socialComment.person.personID != sharedPrefs.userId,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          _socialComment.hasUserLiked! ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
        iconSize: 20,
        onPressed: () {
          _likeComment();
        },
      ),
    );
  }
}
