import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class PostCommentItem extends StatefulWidget {
  @override
  _PostCommentItemState createState() => _PostCommentItemState();
}

class _PostCommentItemState extends State<PostCommentItem> {
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
        padding: EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: SizedBox(
                      height: 38,
                      width: 38,
                      child: CircleAvatar(
                        backgroundColor: Colors.purple.withOpacity(0.5),
                        backgroundImage: OptimizedCacheImageProvider(
                            'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                        child: FlatButton(
                            onPressed: () {
                              print("object");
                            },
                            child: Container()),
                      ))),
              Expanded(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: RichText(
                              maxLines: currentMaxLines ? 10000000 : 3,
                              overflow: TextOverflow.ellipsis,
                              text: new TextSpan(
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'LatoLight'),
                                children: <TextSpan>[
                                  new TextSpan(
                                      text: 'professor_mnm967',
                                      style: new TextStyle(
                                          fontFamily: 'LatoBlack')),
                                  new TextSpan(
                                      text:
                                          '\tHello World. The quick brown fox jumped over the lazy dog.'),
                                ],
                              ),
                            )),
                        Padding(
                            padding:
                                EdgeInsets.only(left: 16, right: 8, top: 3),
                            child: Text(
                              "6 Hours Ago · 23 likes",
                              style: new TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                  fontFamily: 'Lato'),
                            )),
                      ],
                    )),
              ),
              IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    print("yolo");
                  })
            ]));
  }
}
