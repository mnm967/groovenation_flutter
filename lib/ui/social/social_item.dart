import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/ui/social/comment_item.dart';
import 'package:groovenation_flutter/ui/social/comments_dialog.dart';
import 'package:groovenation_flutter/widgets/custom_cache_image_widget.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SocialItem extends StatefulWidget {
  final bool showClose;
  SocialItem({@required this.showClose});

  @override
  _SocialItemState createState() => _SocialItemState(showClose: showClose);
}

class _SocialItemState extends State<SocialItem> {
  bool showClose = false;
  _SocialItemState({this.showClose});

  final FlareControls flareControls = FlareControls();

  @override
  Widget build(BuildContext context) {
    return socialItem(context);
  }

  Widget socialItem(BuildContext context) {
    return Wrap(children: [
      Container(
        child: Card(
          color: Colors.deepPurple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
              child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 64,
                          width: 64,
                          child: CircleAvatar(
                            backgroundColor: Colors.purple.withOpacity(0.5),
                            backgroundImage: OptimizedCacheImageProvider(
                                'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/profile_page');
                                }, child: Container()),
                          )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(left: 16, top: 0, right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "professor_mnm967",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'LatoBold',
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_bar,
                                        size: 20,
                                        color: Colors.white.withOpacity(0.4)),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Jive Lounge",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (item) {},
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_vert,
                                  color: Colors.white, size: 28),
                              itemBuilder: (BuildContext context) {
                                return {'Report'}.map((String choice) {
                                  return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice,
                                          style: TextStyle(
                                              color: Colors.deepPurple)));
                                }).toList();
                              },
                            ),
                            Visibility(visible: this.showClose, child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }))
                          ],
                        ),
                      )
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 0),
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          GestureDetector(
                              onDoubleTap: () {
                                print("double");
                                flareControls.play('like');
                              },
                              child: Stack(
                                children: [
                                  CroppedCacheImage(
                                      url:
                                          //'https://c-sf.smule.com/rs-s78/arr/ea/63/5ea2c2ee-8088-4068-bc4f-4a46a2912a7d_1024.jpg'),
                                          'https://images.pexels.com/photos/1185440/pexels-photo-1185440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'),
                                  Container(
                                    child: Center(
                                      child: SizedBox(
                                        width: 128,
                                        height: 128,
                                        child: FlareActor(
                                          'assets/icons/heart.flr',
                                          controller: flareControls,
                                          animation: 'idle',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Visibility(
                              visible: false,
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2),
                                    child: Center(
                                      child: Icon(
                                        FontAwesomeIcons.play,
                                        color: Colors.white,
                                        size: 84,
                                      ),
                                    ),
                                  )))
                        ],
                      ))),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.heart,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {}),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.comment,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {
                          showGeneralDialog(
                            barrierLabel: "Barrier",
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.7),
                            transitionDuration: Duration(milliseconds: 500),
                            context: context,
                            pageBuilder: (con, __, ___) {
                              return CommentsDialog();
                            },
                            transitionBuilder: (_, anim, __, child) {
                              return SlideTransition(
                                position: Tween(
                                        begin: Offset(0, 1), end: Offset(0, 0))
                                    .animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.elasticOut)),
                                child: child,
                              );
                            },
                          );
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
                    child: GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.shareSquare,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: () {}),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    "400 likes",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 18,
                        fontFamily: 'Lato'),
                  ),
                ),
              ),
              CommentItem(),
            ],
          )),
        ),
      )
    ]);
  }
}
