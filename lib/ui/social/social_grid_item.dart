import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_item_dialog.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SocialGridItem extends StatelessWidget {
  final SocialPost socialPost;
  SocialGridItem({@required this.socialPost});

  _showSocialDialog(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (con, __, ___) {
        return SafeArea(
          child: SocialItemDialog(socialPost),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
              .animate(CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OptimizedCacheImage(
      imageUrl: socialPost.mediaURL,
      imageBuilder: (context, imageProvider) => Ink.image(
        image: imageProvider,
        fit: BoxFit.cover,
        child: InkWell(
          onTap: _showSocialDialog(context),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(
        valueColor:
            new AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
        strokeWidth: 2,
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.error,
        color: Colors.white,
        size: 56,
      ),
    );
  }
}
