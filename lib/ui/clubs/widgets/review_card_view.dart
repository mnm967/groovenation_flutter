import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/club_review_item.dart';

class ReviewCardView extends StatelessWidget {
  final Club? club;

  const ReviewCardView({Key? key, this.club}) : super(key: key);

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
                _list(),
                _viewMoreButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: club!.reviews.length,
        itemBuilder: (context, index) {
          return ReviewItem(club!.reviews[index]);
        });
  }

  Widget _title() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, top: 8, bottom: 24),
          child: Text(
            "Latest Reviews",
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: 'Lato'),
          ),
        ),
      ],
    );
  }

  Widget _emptyPrompt() {
    return Visibility(
      visible: club!.reviews.length == 0,
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

  Widget _viewMoreButton(BuildContext context) {
    return Visibility(
      visible: club!.reviews.length != 0,
      child: FlatButton(
        padding: EdgeInsets.all(24),
        onPressed: () {
          Navigator.pushNamed(context, '/club_reviews', arguments: club);
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
