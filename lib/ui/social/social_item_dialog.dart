import 'package:flutter/cupertino.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';

class SocialItemDialog extends StatelessWidget {
  final SocialPost socialPost;
  SocialItemDialog(this.socialPost);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: SocialItem(socialPost: socialPost, showClose: true));
  }
}
