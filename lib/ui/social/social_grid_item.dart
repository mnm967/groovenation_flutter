import 'package:flutter/material.dart';
import 'package:groovenation_flutter/ui/social/social_item_dialog.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SocialGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OptimizedCacheImage(
      imageUrl:
          //'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=250&w=420',
          'https://images.pexels.com/photos/2240772/pexels-photo-2240772.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
      imageBuilder: (context, imageProvider) => Ink.image(
        image: imageProvider,
        fit: BoxFit.cover,
        child: InkWell(
          onTap: () {
            showGeneralDialog(
              barrierLabel: "Barrier",
              barrierDismissible: false,
              barrierColor: Colors.black.withOpacity(0.7),
              transitionDuration: Duration(milliseconds: 500),
              context: context,
              pageBuilder: (con, __, ___) {
                return SafeArea(
                  child: SocialItemDialog(),
                );
              },
              transitionBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                      .animate(CurvedAnimation(
                          parent: anim, curve: Curves.elasticOut)),
                  child: child,
                );
              },
            );
          },
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
