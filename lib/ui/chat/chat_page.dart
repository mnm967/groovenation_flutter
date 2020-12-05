import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 30) {
        if (_scrollToTopVisible != false) {
          setState(() {
            _scrollToTopVisible = false;
          });
        }
      } else {
        if (_scrollToTopVisible != true) {
          setState(() {
            _scrollToTopVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image:'+pickedFile.path.toString());
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        child: AppBar(
              toolbarHeight: 72,
              titleSpacing: 0,
              title: Row(children: [
                Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        print("jjj");
                      }),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: SizedBox(
                        height: 48,
                        width: 48,
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
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      "professor_mnm967",
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'LatoBold',
                          fontSize: 17,
                          color: Colors.white),
                    ),
                  ),
                )
              ]),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    icon: Icon(Icons.notifications_off), onPressed: () {}),
                PopupMenuButton<String>(
                    onSelected: (item) {},
                    itemBuilder: (BuildContext context) {
                      return [
                        'View User',
                        'Mute notifications',
                        'Report',
                        'Block Chats',
                        'Delete Chat'
                      ].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        );
                      }).toList();
                    }),
              ],
              centerTitle: false,
              backgroundColor: Colors.deepPurple,
              // flexibleSpace: Container(
              //   decoration:
              //   BoxDecoration(
              //     image: DecorationImage(
              //         image: OptimizedCacheImageProvider(
              //             'https://jakecoker.files.wordpress.com/2018/09/default-landscapeipad.png?w=1024&h=768&crop=1'),
              //         fit: BoxFit.cover),
              //   ),
              //   child: Container(
              //       height: 256,
              //       color: Colors.black.withOpacity(0.6),
              //       child: SafeArea(
              //           child: Container(
              //         padding: EdgeInsets.all(0),
              //       ))),
              // ),
            ),
        preferredSize: Size.fromHeight(72),
      ),
      body: Stack(
              children: [
                Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              padding: EdgeInsets.only(
                                  top: 16, bottom: 0, left: 16, right: 16),
                              itemCount: 8,
                              itemBuilder: (context, index) {
                                return messageItem(index.isOdd);
                              }),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, bottom: 16, top: 16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 196),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(9)),
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
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 20),
                                      hintText: "Type your Message",
                                      hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.2)),
                                      suffixIcon: IconButton(
                                          icon:
                                              Icon(Icons.image),
                                          color: Colors.white.withOpacity(0.5),
                                          padding: EdgeInsets.only(right: 20),
                                          iconSize: 28,
                                          onPressed: () {
                                            getImage();
                                            //FocusScope.of(context).unfocus();
                                          })),
                                ),
                              ),
                            ))
                      ],
                    )),
                AnimatedOpacity(
                    opacity: _scrollToTopVisible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 250),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 96, right: 16),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(1),
                                borderRadius: BorderRadius.circular(9)),
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _scrollController.animateTo(
                                  0.0,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                );
                              },
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white.withOpacity(1),
                                size: 36,
                              ),
                            ),
                          ),
                        )))
              ],
            ),
    );
  }

  Widget messageItem(bool isRight) {
    return Padding(
        padding: EdgeInsets.only(top: 24),
        child: Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth:
                              ((MediaQuery.of(context).size.width * 0.80))),
                      child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: isRight ? Colors.deepPurple : Colors.white,
                              borderRadius: BorderRadius.circular(9)),
                          child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                  onLongPress: () {
                                    print("yo");
                                  },
                                  child: Container(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: false,
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text("Yo wassup man. Yesterday was lit bro",
                                              textAlign: isRight
                                                  ? TextAlign.end
                                                  : TextAlign.start,
                                              style: TextStyle(
                                                  color: isRight
                                                      ? Colors.white
                                                      : Colors.deepPurple,
                                                  fontFamily: 'Lato',
                                                  fontSize: 16)),
                                        ),
                                      ),
                                      Visibility(
                                        visible: false,
                                        child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(9)),
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              elevation: 1,
                                              child: AspectRatio(aspectRatio: 1/1,
                                              child: OptimizedCacheImage(
                                                //"https://jakecoker.files.wordpress.com/2018/09/default-landscapeipad.png?w=1024&h=768&crop=1",
                                                imageUrl: "https://images.pexels.com/photos/4336969/pexels-photo-4336969.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),),
                                            )),
                                      ),
                                      Visibility(
                                        visible: true,
                                        child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Card(
                                                color: Colors.deepPurple,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                elevation: 3,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        child: Row(children: [
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 0),
                                                              child: SizedBox(
                                                                  height: 48,
                                                                  width: 48,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor: Colors
                                                                        .purple
                                                                        .withOpacity(
                                                                            0.5),
                                                                    backgroundImage:
                                                                        OptimizedCacheImageProvider(
                                                                            'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                                                                    child: FlatButton(
                                                                        onPressed: () {
                                                                          print(
                                                                              "object");
                                                                        },
                                                                        child: Container()),
                                                                  ))),
                                                          Expanded(
                                                            child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            16),
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Shared Post By:",
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Lato',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.white.withOpacity(0.4)),
                                                                      ),
                                                                      Padding(
                                                                          padding: EdgeInsets
                                                                              .zero,
                                                                          child:
                                                                              Text(
                                                                            "professor_mnm967",
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontFamily: 'LatoBold',
                                                                                fontSize: 18,
                                                                                color: Colors.white),
                                                                          )),
                                                                    ])),
                                                          )
                                                        ])),
                                                    AspectRatio(
                                                      aspectRatio: 1,
                                                      child: OptimizedCacheImage(
                                                        //"https://jakecoker.files.wordpress.com/2018/09/default-landscapeipad.png?w=1024&h=768&crop=1",
                                                        imageUrl: "https://images.pexels.com/photos/1185440/pexels-photo-1185440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ))),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: 4, bottom: 4, left: 4),
                                        child: Text("2020/04/22, 06:30",
                                            style: TextStyle(
                                                color: isRight
                                                    ? Colors.white
                                                        .withOpacity(0.7)
                                                    : Colors.deepPurple
                                                        .withOpacity(0.8),
                                                fontFamily: 'Lato',
                                                fontSize: 13)),
                                      ),
                                    ],
                                  ))))))
                ],
              )
            ]));
  }
}
