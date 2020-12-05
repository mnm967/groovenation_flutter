import 'package:flutter/material.dart';

class CommentItem extends StatefulWidget {
  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
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
                      text: 'professor_mnm967',
                      style: new TextStyle(fontFamily: 'LatoBlack')),
                  new TextSpan(
                      text:
                          '\tLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
                ],
              ),
            )),
      ),
    );
  }
}