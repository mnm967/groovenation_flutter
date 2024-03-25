import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/dialogs/social_item_dialog.dart';

class MomentsCardView extends StatelessWidget {
  final Club? club;

  const MomentsCardView({Key? key, this.club}) : super(key: key);

  _showSocialDialog(BuildContext context, SocialPost socialPost) {
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
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        child: Card(
          color: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _title(),
                _emptyPrompt(),
                club!.moments.isEmpty ? Container() : _list(context),
                club!.moments.isEmpty ? Container() : _viewMoreButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyPrompt() {
    return Visibility(
      visible: club!.moments.isEmpty,
      child: Padding(
        padding: EdgeInsets.only(top: 16, bottom: 32),
        child: Center(
          child: Text(
            "Nothing to See Yet",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 18,
                fontFamily: 'Lato'),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, top: 8, bottom: 24),
          child: Text(
            "Moments",
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: 'Lato'),
          ),
        ),
      ],
    );
  }

  Widget _list(BuildContext context) {
    return Visibility(
      visible: club!.reviews.length != 0,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        color: Colors.transparent,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          children: List.generate(club!.moments.length, (index) {
            return Ink.image(
              image: CachedNetworkImageProvider(club!.moments[index].mediaURL!),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: _showSocialDialog(context, club!.moments[index]),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _viewMoreButton(BuildContext context) {
    return Visibility(
      visible: club!.reviews.length != 0,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(24),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/club_moments', arguments: club);
        },
        child: Center(
          child: Text(
            "View More",
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontFamily: 'Lato'),
          ),
        ),
      ),
    );
  }
}
