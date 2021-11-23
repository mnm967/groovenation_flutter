import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_item.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
      header: CustomMaterialClassicHeader(),
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
                        key: Key(socialPosts[index].postID!),
                        socialPost: socialPosts[index],
                        showClose: false),
                  );
                },
                childCount: socialPosts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
