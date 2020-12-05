import 'package:flutter/cupertino.dart';
import 'package:groovenation_flutter/ui/social/social_item.dart';

class SocialItemDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child : SocialItem(showClose: true)
    );
  }
}