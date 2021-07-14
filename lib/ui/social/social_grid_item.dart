import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/integers.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_item_dialog.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SocialGridItem extends StatefulWidget {
  final SocialPost socialPost;
  SocialGridItem({@required this.socialPost, @required Key key})
      : super(key: key);

  @override
  _SocialGridItemState createState() =>
      _SocialGridItemState(socialPost: socialPost);
}

class _SocialGridItemState extends State<SocialGridItem> {
  final SocialPost socialPost;
  _SocialGridItemState({@required this.socialPost});

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
  void initState() {
    super.initState();

    if(socialPost.postType == SOCIAL_POST_TYPE_VIDEO) _setupVideoImage();
  }

  Image videoThumbnail;

  _setupVideoImage() async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: socialPost.mediaURL,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 512,
      maxHeight: 512,
      quality: 50,
    );

    setState(() {
      videoThumbnail = Image.memory(
        uint8list,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (socialPost.postType == SOCIAL_POST_TYPE_VIDEO) {
      return videoThumbnail == null
          ? Container(
              color: Colors.deepPurple,
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7)),
                strokeWidth: 2,
              )),
            )
          : AspectRatio(
              aspectRatio: 1.0,
              child: FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _showSocialDialog(context);
                  },
                  child: Stack(
                    children: [
                      videoThumbnail,
                      Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white.withOpacity(0.9),
                          size: 72,
                        ),
                      ),
                    ],
                  )));
    }

    return OptimizedCacheImage(
      imageUrl: socialPost.mediaURL,
      imageBuilder: (context, imageProvider) => Ink.image(
        image: imageProvider,
        fit: BoxFit.cover,
        child: InkWell(
          onTap: () {
            _showSocialDialog(context);
          },
        ),
      ),
      placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
        valueColor:
            new AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
        strokeWidth: 2,
      )),
      errorWidget: (context, url, error) => Icon(
        Icons.error,
        color: Colors.white,
        size: 56,
      ),
    );
  }
}
