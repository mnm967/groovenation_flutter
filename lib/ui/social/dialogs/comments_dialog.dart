import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/social/social_comments_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/widgets/post_comment_item.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommentsDialog extends StatefulWidget {
  final SocialPost? socialPost;
  CommentsDialog({required this.socialPost});

  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  SocialPost? socialPost;

  final ScrollController _commentsScrollController = new ScrollController();
  final _commentsRefreshController = RefreshController(initialRefresh: false);
  final TextEditingController _textEditingController = TextEditingController();

  List<SocialComment>? _comments = [];
  int _commentsPage = 0;
  bool _commentAdded = false;

  @override
  void initState() {
    super.initState();
    socialPost = widget.socialPost;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final SocialCommentsCubit commentsSocialCubit =
          BlocProvider.of<SocialCommentsCubit>(context);
      commentsSocialCubit.getComments(_commentsPage, socialPost!.postID);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _commentsRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: double.infinity,
        child: SizedBox.expand(
          child: commentPage(),
        ),
        margin: EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void sendSocialComment(String comment) {
    final SocialCommentsCubit commentsSocialCubit =
        BlocProvider.of<SocialCommentsCubit>(context);
    _commentAdded = true;
    setState(
      () {
        SocialComment newComment = SocialComment(
            null,
            SocialPerson(
              sharedPrefs.userId,
              sharedPrefs.username,
              sharedPrefs.profilePicUrl,
              sharedPrefs.coverPicUrl,
              false,
              false,
              sharedPrefs.userFollowersCount
            ),
            DateTime.now(),
            0,
            false,
            comment);

        _comments!.insert(0, newComment);
      },
    );

    commentsSocialCubit.addComment(socialPost!.postID, comment);

    _commentsScrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _loadMoreComments() {
    final SocialCommentsCubit commentsSocialCubit =
        BlocProvider.of<SocialCommentsCubit>(context);
    commentsSocialCubit.getComments(_commentsPage + 1, socialPost!.postID);

    setState(() {
      _commentsPage = _commentsPage + 1;
    });
  }

  Widget commentPage() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _commentInput(),
            _commentsBlocContainer(),
          ],
        ),
      ),
    );
  }

  Widget _commentsBlocContainer() {
    return BlocConsumer<SocialCommentsCubit, SocialCommentsState>(
      listener: (context, socialState) {
        if (socialState is SocialCommentsLoadedState) {
          _commentsRefreshController.loadComplete();
        }

        if (socialState is SocialCommentsErrorState) {
          _commentsRefreshController.loadFailed();
        }
      },
      builder: (context, socialState) {
        if (socialState is SocialCommentsLoadingState && _commentsPage == 0)
          return _circularProgress();

        bool? hasReachedMax = false;

        if (socialState is SocialCommentsLoadedState) {
          if (_commentsPage == 0 && !_commentAdded)
            _comments = socialState.socialComments;
          else if (_commentAdded) {
            _commentAdded = false;
          } else {
            _comments!.addAll(socialState.socialComments!);
            _commentsRefreshController.loadComplete();
          }

          hasReachedMax = socialState.hasReachedMax;
        }

        if (hasReachedMax!) {
          _commentsRefreshController.loadNoData();
        }

        return Expanded(
          child: SmartRefresher(
            controller: _commentsRefreshController,
            header: CustomMaterialClassicHeader(),
            footer: ClassicFooter(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
              noDataText: "You've reached the end of the line",
              failedText: "Something Went Wrong",
            ),
            onLoading: _loadMoreComments,
            enablePullDown: false,
            enablePullUp: true,
            child: _commentList(),
          ),
        );
      },
    );
  }

  Widget _commentList() {
    return ListView.builder(
      controller: _commentsScrollController,
      physics: AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 8, bottom: 8),
      itemCount: _comments!.length,
      itemBuilder: (context, index) {
        return PostCommentItem(
          Key(
            _comments![index].hashCode.toString(),
          ),
          _comments![index],
        );
      },
    );
  }

  Widget _circularProgress() {
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

  InputDecoration _commentInputDecoration() => InputDecoration(
        hintMaxLines: 3,
        hintText: "Add Your Comment",
        hintStyle: TextStyle(
            fontFamily: 'Lato',
            color: Colors.white.withOpacity(0.2),
            fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.5), width: 1.0),
        ),
        suffixIcon: Visibility(
          visible: _textEditingController.text.isNotEmpty,
          child: IconButton(
            icon: Icon(Icons.send),
            color: Colors.white.withOpacity(0.5),
            padding: EdgeInsets.only(right: 20),
            iconSize: 20,
            onPressed: () {
              sendSocialComment(_textEditingController.text);
              setState(() {
                _textEditingController.text = "";
              });

              FocusScope.of(context).unfocus();
            },
          ),
        ),
      );

  Widget _commentInput() {
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              onChanged: (text) {
                setState(() {});
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorColor: Colors.white.withOpacity(0.7),
              style: TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18),
              decoration: _commentInputDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.only(top: 1, right: 8),
                child: Text(
                  "Comments",
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'LatoBold',
                      fontSize: 20,
                      color: Colors.white),
                )),
          )),
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 24,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
