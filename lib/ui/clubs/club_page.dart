import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ClubPage extends StatefulWidget {
  final Club club;
  ClubPage(this.club);

  @override
  _ClubPageState createState() => _ClubPageState(club: club);
}

class _ClubPageState extends State<ClubPage> {
  ScrollController _scrollController = new ScrollController();

  Club club;
  _ClubPageState({this.club});

  @override
  void initState() {
    super.initState();
    
    print("Found Screene : " + club.name+ club.clubID);
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPersistentHeader(
                delegate: MySliverAppBar(
                  expandedHeight: 392.0,
                  statusBarHeight: MediaQuery.of(context).padding.top,
                ),
                floating: false,
                pinned: true,
              ),
              SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.zero,
                              child: Text(
                                "Jive Lounge",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontFamily: 'LatoBold'),
                              )),
                          RatingBar(
                            initialRating: 3.4,
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
                          // Padding(
                          //     padding: EdgeInsets.only(top: 8),
                          //     child: Text(
                          //       "www.jivelounge.co.za",
                          //       style: TextStyle(
                          //           color:
                          //               Colors.white.withOpacity(0.5),
                          //           fontSize: 24,
                          //           fontFamily: 'Lato'),
                          //     )),
                          // Padding(
                          //     padding: EdgeInsets.only(top: 8),
                          //     child: Text(
                          //       "+27 65 800 9321",
                          //       style: TextStyle(
                          //           color:
                          //               Colors.white.withOpacity(0.5),
                          //           fontSize: 24,
                          //           fontFamily: 'Lato'),
                          //     )),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.globeAfrica,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.facebookF,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.twitter,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: RawMaterialButton(
                                      onPressed: () {},
                                      constraints: BoxConstraints.expand(
                                          width: 72, height: 72),
                                      elevation: 0,
                                      child: Center(
                                          child: Icon(
                                        FontAwesomeIcons.instagram,
                                        color: Colors.white,
                                        size: 24.0,
                                      )),
                                      padding: EdgeInsets.all(16.0),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1, color: Colors.white)),
                                    )),
                              ],
                            ),
                          ),
                          cardView(FontAwesomeIcons.mapMarkerAlt,
                              "417 5th Avenue, Apartment 10B, 10016"),
                          cardView(FontAwesomeIcons.mobile, "+27 65 800 9321"),
                          cardView(FontAwesomeIcons.globeAfrica,
                              "www.jivelounge.co.za"),
                          eventsCardView(),
                          imagesCardView(),
                          momentsCardView(),
                          reviewsCardView(),
                          Padding(
                              padding: EdgeInsets.only(bottom: 36),
                              child: userReviewCardView())
                        ],
                      )))
            ],
          ),
        ),
      ],
    );
  }

  Widget eventsCardView() {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          child: Card(
            color: Colors.deepPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 8, bottom: 16),
                          child: Text(
                            "Upcoming Events",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Lato'),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return miniEventItem();
                        }),
                    FlatButton(
                        padding: EdgeInsets.all(24),
                        onPressed: () {},
                        child: Center(
                          child: Text(
                            "View More",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 18,
                                fontFamily: 'Lato'),
                          ),
                        ))
                  ],
                )),
          ),
        ));
  }

  Widget momentsCardView() {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          child: Card(
            color: Colors.deepPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 8, bottom: 24),
                          child: Text(
                            "Moments",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Lato'),
                          ),
                        ),
                      ],
                    ),
                    Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                        color: Colors.transparent,
                        child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          crossAxisCount: 2,
                          children: List.generate(6, (index) {
                            if (index.isOdd) {
                              return Ink.image(
                                image: OptimizedCacheImageProvider(
                                  'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                                ),
                                fit: BoxFit.cover,
                                child: InkWell(
                                  onTap: () {},
                                ),
                              );
                            }
                            return Ink.image(
                              image: OptimizedCacheImageProvider(
                                'https://images.pexels.com/photos/2240771/pexels-photo-2240771.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                              ),
                              fit: BoxFit.cover,
                              child: InkWell(
                                onTap: () {},
                              ),
                            );
                          }),
                        )),
                    FlatButton(
                        padding: EdgeInsets.all(24),
                        onPressed: () {},
                        child: Center(
                          child: Text(
                            "View More",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 18,
                                fontFamily: 'Lato'),
                          ),
                        ))
                  ],
                )),
          ),
        ));
  }

  Widget reviewsCardView() {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          child: Card(
            color: Colors.deepPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 8, bottom: 24),
                          child: Text(
                            "Latest Reviews",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Lato'),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return ReviewItem();
                        }),
                    Visibility(
                        visible: true,
                        child: FlatButton(
                            padding: EdgeInsets.all(24),
                            onPressed: () {},
                            child: Center(
                              child: Text(
                                "View More",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                    fontFamily: 'Lato'),
                              ),
                            ))),
                    Visibility(
                        visible: false,
                        child: Container(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7)),
                            strokeWidth: 2,
                          ),
                        ))
                  ],
                )),
          ),
        ));
  }

  Widget imagesCardView() {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
            width: double.infinity,
            child: Card(
              color: Colors.deepPurple,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                  height: 296,
                  child: CarouselSlider(
                      options: CarouselOptions(
                          height: 296,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 8),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          disableCenter: true),
                      items: [1, 2, 3, 4, 5].map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            if (i.isEven) {
                              return Container(
                                  decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: OptimizedCacheImageProvider(
                                      'https://images.pexels.com/photos/2747446/pexels-photo-2747446.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'),
                                  fit: BoxFit.cover,
                                ),
                              ));
                            }
                            return Container(
                                decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: OptimizedCacheImageProvider(
                                      'https://images.pexels.com/photos/2034851/pexels-photo-2034851.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260'),
                                  fit: BoxFit.cover),
                            ));
                          },
                        );
                      }).toList())),
            )));
  }

  Widget userReviewCardView() {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          child: Card(
            color: Colors.deepPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 8, bottom: 24),
                          child: Text(
                            "Leave a Review",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Lato'),
                          ),
                        ),
                      ],
                    ),
                    RatingBar(
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.zero,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.purple,
                      ),
                      unratedColor: Colors.white,
                      itemSize: 64,
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          maxLength: 1000,
                          maxLengthEnforced: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          cursorColor: Colors.white.withOpacity(0.7),
                          style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18),
                          decoration: InputDecoration(
                            hintMaxLines: 3,
                            hintText:
                                "Your review will be submitted once you type something",
                            border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                                borderSide: const BorderSide(
                                    color: Color(0xffE65AB9), width: 1.0)),
                          ),
                        ))
                  ],
                )),
          ),
        ));
  }

  Widget miniEventItem() {
    return FlatButton(
        onPressed: () {},
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
                height: 76,
                width: 76,
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Container(
                      child: Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Feb",
                            style: TextStyle(
                              fontFamily: 'LatoBold',
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "21",
                            style: TextStyle(
                              fontFamily: 'LatoBold',
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )),
                    ))),
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: 20, top: 0, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Helix After Party",
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'LatoBold',
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.4)),
                      )),
                ],
              ),
            )),
          ],
        ));
  }

  Widget cardView(IconData icon, String text) {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          child: Card(
            color: Colors.deepPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: FlatButton(
                padding: EdgeInsets.all(24),
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                    Flexible(
                        child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Lato'),
                      ),
                    ))
                  ],
                )),
          ),
        ));
  }
}

class ReviewItem extends StatefulWidget {
  @override
  _ReviewItemState createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
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
        children: [
          SizedBox(
              height: 76,
              width: 76,
              child: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.5),
                backgroundImage: OptimizedCacheImageProvider(
                    'https://www.kolpaper.com/wp-content/uploads/2020/05/Wallpaper-Tokyo-Ghoul-for-Desktop.jpg'),
                child: FlatButton(onPressed: () {}, child: Container()),
              )),
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: 20, top: 0, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "professor_mnm967",
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'LatoBold',
                      fontSize: 20,
                      color: Colors.white),
                ),
                RatingBar(
                  initialRating: 3.4,
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
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      textAlign: TextAlign.start,
                      maxLines: currentMaxLines ? 10000 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.4)),
                    )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double statusBarHeight;

  MySliverAppBar({
    @required this.expandedHeight,
    @required this.statusBarHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        height: expandedHeight,
        child: Stack(children: [
          Container(
              height: (expandedHeight - 36),
              child: Stack(
                fit: StackFit.expand,
                overflow: Overflow.visible,
                children: [
                  Positioned.fill(
                      child: OptimizedCacheImage(
                    imageUrl: "https://images.pexels.com/photos/4784/alcohol-bar-party-cocktail.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                    fit: BoxFit.cover,
                  )),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  SafeArea(child: topAppBar(context, shrinkOffset)),
                ],
              )),
          Container(
            height: (expandedHeight),
            width: double.infinity,
            child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          height: 72,
                          width: 72,
                          child: Card(
                            elevation: 6.0,
                            clipBehavior: Clip.antiAlias,
                            shape: CircleBorder(),
                            color: Colors.deepPurple,
                            child: Container(
                                child: FlatButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {},
                                    child: Center(
                                      child: Icon(
                                        FontAwesomeIcons.mapMarkedAlt,
                                        color: Colors.white,
                                      ),
                                    ))),
                          ),
                        )),
                  ],
                )),
          )
        ]));
  }

  Stack topAppBar(BuildContext context, double shrinkOffset) =>
      Stack(children: [
        Row(children: [
          Expanded(
            child: Container(
                child: Stack(
              children: [
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
                    child: Container(
                        padding: EdgeInsets.zero,
                        child: Container(
                            width: double.infinity,
                            height: expandedHeight,
                            child: Stack(
                              children: [
                                Opacity(
                                    opacity:
                                        (1 - shrinkOffset / expandedHeight),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 16, right: 16),
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(9)),
                                            child: FlatButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {},
                                              child: Icon(
                                                Icons.star_border,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          )),
                                    )),
                                Opacity(
                                    opacity:
                                        (1 - shrinkOffset / expandedHeight),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 16, right: 16),
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(900)),
                                            child: FlatButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Icon(
                                                Icons.arrow_back_ios,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          )),
                                    )),
                              ],
                            ))),
                  ),
                ),
              ],
            )),
          ),
        ]),
      ]);

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => statusBarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
