import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CroppedCacheImage extends StatelessWidget {
  final String url;
  CroppedCacheImage({this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
        valueColor:
            new AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
        strokeWidth: 2,
      )),
      errorWidget: (context, url, error) => Center(
          child: Icon(
        Icons.error,
        color: Colors.white,
        size: 56,
      )),
    );
  }
}
