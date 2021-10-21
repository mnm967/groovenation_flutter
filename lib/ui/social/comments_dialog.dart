import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/social_comments_cubit.dart';
import 'package:groovenation_flutter/cubit/state/social_comments_state.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/post_comment_item.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommentsDialog extends StatefulWidget {
  final SocialPost socialPost;
  CommentsDialog({@required this.socialPost});

  @override
  _CommentsDialogState createState() =>
      _CommentsDialogState(socialPost: socialPost);
}

class _CommentsDialogState extends State<CommentsDialog> {
  SocialPost socialPost;

  _CommentsDialogState({@required this.socialPost});

  final _commentsRefreshController = RefreshController(initialRefresh: false);
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final SocialCommentsCubit commentsSocialCubit =
          BlocProvider.of<SocialCommentsCubit>(context);
      commentsSocialCubit.getComments(commentsPage, socialPost.postID);
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

  void addSocialComment(String comment) {
    final SocialCommentsCubit commentsSocialCubit =
        BlocProvider.of<SocialCommentsCubit>(context);
    commentAdded = true;
    setState(() {
      SocialComment newCom = SocialComment(
          null,
          SocialPerson(
              sharedPrefs.userId,
              sharedPrefs.username,
              sharedPrefs.profilePicUrl,
              sharedPrefs.coverPicUrl,
              false,
              false,),
              
          DateTime.now(),
          0,
          false,
          comment);

      comments.insert(0, newCom);
    });

    commentsSocialCubit.addComment(socialPost.postID, comment);
  }

  List<SocialComment> comments = [];
  int commentsPage = 0;
  bool commentAdded = false;

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
                Padding(
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
                    )),
                Padding(
                    padding:
                        EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
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
                            decoration: InputDecoration(
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
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.0)),
                                suffixIcon: Visibility(
                                    visible:
                                        _textEditingController.text.isNotEmpty,
                                    child: IconButton(
                                        icon: Icon(Icons.send),
                                        color: Colors.white.withOpacity(0.5),
                                        padding: EdgeInsets.only(right: 20),
                                        iconSize: 20,
                                        onPressed: () {
                                          addSocialComment(
                                              _textEditingController.text);
                                          setState(() {
                                            _textEditingController.text = "";
                                          });
                                          FocusScope.of(context).unfocus();
                                        }))),
                          ),
                        ),
                      ],
                    )),
                BlocConsumer<SocialCommentsCubit, SocialCommentsState>(
                    listener: (context, socialState) {
                  if (socialState is SocialCommentsLoadedState) {
                    _commentsRefreshController.loadComplete();
                  }

                  if (socialState is SocialCommentsErrorState) {
                    _commentsRefreshController.loadFailed();
                  }
                }, builder: (context, socialState) {
                  if (socialState is SocialCommentsLoadingState) {
                    return Padding(
                        padding: EdgeInsets.only(top: 64),
                        child: Center(
                            child: SizedBox(
                          height: 56,
                          width: 56,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )));
                  }

                  bool hasReachedMax = false;

                  if (socialState is SocialCommentsLoadedState) {
                    if (commentsPage == 0 && !commentAdded)
                      comments = socialState.socialComments;
                    else if (commentAdded) {
                      commentAdded = false;
                    } else {
                      comments.addAll(socialState.socialComments);
                      _commentsRefreshController.loadComplete();
                    }

                    hasReachedMax = socialState.hasReachedMax;
                  }

                  if (hasReachedMax) {
                    _commentsRefreshController.loadNoData();
                  }

                  return Expanded(
                      child: SmartRefresher(
                          controller: _commentsRefreshController,
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
                            final SocialCommentsCubit commentsSocialCubit =
                                BlocProvider.of<SocialCommentsCubit>(context);
                            commentsSocialCubit.getMoreComments(
                                commentsPage + 1, socialPost.postID);

                            commentsPage = commentsPage + 1;
                          },
                          enablePullDown: false,
                          enablePullUp: true,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      return PostCommentItem(Key(comments[index].hashCode.toString()), comments[index]);
                                    }),
                              ],
                            ),
                          )));
                }),
              ]),
        ));
  }
}
