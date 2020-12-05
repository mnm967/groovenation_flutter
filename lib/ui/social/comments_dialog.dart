import 'package:flutter/material.dart';
import 'package:groovenation_flutter/ui/social/post_comment_item.dart';

class CommentsDialog extends StatefulWidget {
  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: double.infinity,
        child: SizedBox.expand(
          child: commentPage(),
        ),
        margin: EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget commentPage() {
    return Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
            top: 16,
            bottom: 16,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 24, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(top: 1, right: 8),
                              child: Text(
                                "Comments",
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'LatoBold',
                                    fontSize: 20,
                                    color: Colors.white),
                              )),
                        )),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconSize: 24,
                          color: Colors.white,
                        ),
                      ],
                    )),
                Padding(
                    padding:
                        EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            cursorColor: Colors.white.withOpacity(0.7),
                            style: TextStyle(
                                fontFamily: 'Lato',
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 18),
                            decoration: InputDecoration(
                                hintMaxLines: 3,
                                hintText: "Type your comment",
                                border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.0)),
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.send),
                                    color: Colors.white.withOpacity(0.5),
                                    padding: EdgeInsets.only(right: 20),
                                    iconSize: 20,
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                    })),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                    child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 8),
                        child: PostCommentItem(),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(right: 16, left: 16),
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return PostCommentItem();
                          }),
                    ],
                  ),
                )),
              ]),
        ));
  }
}
