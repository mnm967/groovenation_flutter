import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/social_person.dart';

class CommentItem extends StatefulWidget {
  final SocialPerson socialPerson;
  final String? comment;

  CommentItem(this.socialPerson, this.comment);

  @override
  _CommentItemState createState() => _CommentItemState(socialPerson, comment);
}

class _CommentItemState extends State<CommentItem> {
  bool currentMaxLines = false;
  final SocialPerson socialPerson;
  final String? comment;

  _CommentItemState(this.socialPerson, this.comment);

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
      padding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
          child: RichText(
            maxLines: currentMaxLines ? 10000000 : 3,
            overflow: TextOverflow.ellipsis,
            text: new TextSpan(
              style: new TextStyle(
                  color: Colors.white, fontSize: 16, fontFamily: 'LatoLight'),
              children: <TextSpan>[
                new TextSpan(
                    text: socialPerson.personUsername,
                    style: new TextStyle(fontFamily: 'LatoBlack')),
                new TextSpan(text: '\t$comment'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
