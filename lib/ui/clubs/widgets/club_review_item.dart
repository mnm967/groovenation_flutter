import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:groovenation_flutter/models/club_review.dart';

class ReviewItem extends StatefulWidget {
  final ClubReview review;
  ReviewItem(this.review);

  @override
  _ReviewItemState createState() => _ReviewItemState(review);
}

class _ReviewItemState extends State<ReviewItem> {
  final ClubReview review;
  _ReviewItemState(this.review);

  bool currentMaxLines = false;

  @override
  void initState() {
    super.initState();
    currentMaxLines = false;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        setState(() {
          currentMaxLines = !currentMaxLines;
        });
      },
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_profilePicture(), _reviewContent()],
      ),
    );
  }

  Widget _profilePicture() {
    return SizedBox(
      height: 76,
      width: 76,
      child: CircleAvatar(
        backgroundColor: Colors.purple.withOpacity(0.5),
        backgroundImage:
            CachedNetworkImageProvider(review.person!.personProfilePicURL!),
        child: FlatButton(
          onPressed: () {},
          child: Container(),
        ),
      ),
    );
  }

  Widget _reviewContent() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.person!.personUsername!,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
            ),
            RatingBar.builder(
              initialRating: review.rating!.toDouble(),
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.only(top: 8),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.purple,
              ),
              ignoreGestures: true,
              itemSize: 24,
              onRatingUpdate: (rating) {},
            ),
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                review.review!,
                textAlign: TextAlign.start,
                maxLines: currentMaxLines ? 10000 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
