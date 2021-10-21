import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/club_reviews_cubit.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/ui/social/social_item_dialog.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  @override
  void initState() {
    super.initState();

    if (club.userReview != null)
      _currentUserRating = club.userReview.rating.toDouble();
    if (club.userReview != null) _currentUserReview = club.userReview.review;
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    final FavouritesClubsCubit favouritesClubsCubit =
        BlocProvider.of<FavouritesClubsCubit>(context);

    if (club.userReview != null)
      print("urev: " + club.userReview.rating.toString());

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              BlocBuilder<FavouritesClubsCubit, ClubsState>(
                  builder: (context, favouriteEventsState) {
                bool clubIsFav =
                    favouritesClubsCubit.checkClubExists(club.clubID);

                return SliverPersistentHeader(
                  delegate: MySliverAppBar(
                      expandedHeight: 392.0,
                      statusBarHeight: MediaQuery.of(context).padding.top,
                      imageUrl: club.images[0],
                      isClubLiked: clubIsFav,
                      onFavButtonClick: () {
                        if (favouritesClubsCubit.checkClubExists(club.clubID)) {
                          favouritesClubsCubit.removeClub(club);
                        } else
                          favouritesClubsCubit.addClub(club);
                      },
                      latitude: club.latitude,
                      longitude: club.longitude),
                  floating: false,
                  pinned: true,
                );
              }),
              SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.zero,
                              child: Text(
                                club.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontFamily: 'LatoBold'),
                              )),
                          RatingBar.builder(
                            initialRating: club.averageRating.toDouble(),
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
                            padding: EdgeInsets.only(top: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Visibility(
                                    visible: club.webLink != null,
                                    child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            _launchURL(club.webLink);
                                          },
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
                                                  width: 1,
                                                  color: Colors.white)),
                                        ))),
                                Visibility(
                                    visible: club.facebookLink != null,
                                    child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            _launchURL(club.facebookLink);
                                          },
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
                                                  width: 1,
                                                  color: Colors.white)),
                                        ))),
                                Visibility(
                                    visible: club.twitterLink != null,
                                    child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            _launchURL(club.twitterLink);
                                          },
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
                                                  width: 1,
                                                  color: Colors.white)),
                                        ))),
                                Visibility(
                                    visible: club.instagramLink != null,
                                    child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            _launchURL(club.instagramLink);
                                          },
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
                                                  width: 1,
                                                  color: Colors.white)),
                                        ))),
                              ],
                            ),
                          ),
                          cardView(FontAwesomeIcons.mapMarkerAlt, club.address),
                          cardView(FontAwesomeIcons.mobile, club.phoneNumber),
                          club.webLink != null
                              ? cardView(
                                  FontAwesomeIcons.globeAfrica, club.webLink)
                              : Padding(padding: EdgeInsets.zero),
                          eventsCardView(),
                          imagesCardView(),
                          //momentsCardView(),
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
                    Visibility(
                        visible: club.upcomingEvents.length == 0,
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
                            ))),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: club.upcomingEvents.length,
                        itemBuilder: (context, index) {
                          return miniEventItem(club.upcomingEvents[index]);
                        }),
                    Visibility(
                        visible: club.upcomingEvents.length != 0,
                        child: FlatButton(
                            padding: EdgeInsets.all(24),
                            onPressed: () {
                              Navigator.pushNamed(context, '/club_events',
                                  arguments: club);
                            },
                            child: Center(
                              child: Text(
                                "View More",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                    fontFamily: 'Lato'),
                              ),
                            )))
                  ],
                )),
          ),
        ));
  }

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
                    Visibility(
                        visible: club.reviews.length == 0,
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
                            ))),
                    Visibility(
                        visible: club.reviews.length != 0,
                        child: Card(
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
                              children:
                                  List.generate(club.moments.length, (index) {
                                return Ink.image(
                                  image: CachedNetworkImageProvider(
                                      club.moments[index].mediaURL),
                                  fit: BoxFit.cover,
                                  child: InkWell(
                                    onTap: _showSocialDialog(
                                        context, club.moments[index]),
                                  ),
                                );
                              }),
                            ))),
                    Visibility(
                        visible: club.reviews.length != 0,
                        child: FlatButton(
                            padding: EdgeInsets.all(24),
                            onPressed: () {
                              Navigator.pushNamed(context, '/club_moments',
                                  arguments: club);
                            },
                            child: Center(
                              child: Text(
                                "View More",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 18,
                                    fontFamily: 'Lato'),
                              ),
                            )))
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
                    Visibility(
                        visible: club.reviews.length == 0,
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
                            ))),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: club.reviews.length,
                        itemBuilder: (context, index) {
                          return ReviewItem(club.reviews[index]);
                        }),
                    Visibility(
                        visible: club.reviews.length != 0,
                        child: FlatButton(
                            padding: EdgeInsets.all(24),
                            onPressed: () {
                              Navigator.pushNamed(context, '/club_reviews',
                                  arguments: club);
                            },
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
                      items: club.images.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(i),
                                  fit: BoxFit.cover),
                            ));
                          },
                        );
                      }).toList())),
            )));
  }

  double _currentUserRating = 0.0;
  String _currentUserReview = "";
  TextEditingController _reviewInputController = TextEditingController();

  Widget userReviewCardView() {
    _reviewInputController.value = TextEditingValue(
      text: _currentUserReview,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _currentUserReview.length),
      ),
    );

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
                    RatingBar.builder(
                      initialRating: _currentUserRating,
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
                        setState(() {
                          _currentUserRating = rating;
                        });

                        final NearbyClubsCubit nearbyClubsCubit =
                            BlocProvider.of<NearbyClubsCubit>(context);
                        final TopClubsCubit topClubsCubit =
                            BlocProvider.of<TopClubsCubit>(context);
                        final FavouritesClubsCubit favouriteClubsCubit =
                            BlocProvider.of<FavouritesClubsCubit>(context);

                        if (_reviewInputController.text.isNotEmpty &&
                            _currentUserRating > 0) {
                          num newClubRating = club.averageRating;

                          if (club.userReview != null) {
                            num tave = club.averageRating * club.totalReviews;
                            tave = tave - club.userReview.rating;
                            tave = tave + rating;
                            newClubRating = tave / club.totalReviews;
                          } else {
                            num tave = club.averageRating * club.totalReviews;
                            setState(() {
                              club.totalReviews++;
                            });
                            tave = tave + rating;
                            newClubRating = tave / (club.totalReviews);
                          }

                          setState(() {
                            club.averageRating = newClubRating.toDouble();
                            if (club.userReview != null)
                              club.userReview.rating = rating;
                          });

                          final AddClubReviewCubit addClubReviewCubit =
                              BlocProvider.of<AddClubReviewCubit>(context);

                          addClubReviewCubit.addReview(club.clubID,
                              _currentUserRating, _reviewInputController.text);

                          if (club.userReview != null) {
                            nearbyClubsCubit.updateUserReviewClub(club);
                            topClubsCubit.updateUserReviewClub(club);
                            favouriteClubsCubit.updateUserReviewClub(club);
                          }
                        }
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          controller: _reviewInputController,
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          cursorColor: Colors.white.withOpacity(0.7),
                          onChanged: (text) {
                            setState(() {
                              _currentUserReview = text;
                            });

                            final NearbyClubsCubit nearbyClubsCubit =
                                BlocProvider.of<NearbyClubsCubit>(context);
                            final TopClubsCubit topClubsCubit =
                                BlocProvider.of<TopClubsCubit>(context);
                            final FavouritesClubsCubit favouriteClubsCubit =
                                BlocProvider.of<FavouritesClubsCubit>(context);

                            if (text.isNotEmpty && _currentUserRating > 0) {
                              num newClubRating = club.averageRating;

                              if (club.userReview != null &&
                                  _currentUserRating !=
                                      club.userReview.rating) {
                                num tave =
                                    club.averageRating * club.totalReviews;
                                tave = tave - club.userReview.rating;
                                tave = tave + _currentUserRating;
                                newClubRating = tave / club.totalReviews;
                              } else {
                                num tave =
                                    club.averageRating * club.totalReviews;
                                setState(() {
                                  club.totalReviews++;
                                });
                                tave = tave + _currentUserRating;
                                newClubRating = tave / (club.totalReviews);
                              }

                              setState(() {
                                club.averageRating = newClubRating.toDouble();
                              });

                              final AddClubReviewCubit addClubReviewCubit =
                                  BlocProvider.of<AddClubReviewCubit>(context);

                              addClubReviewCubit.addReview(
                                  club.clubID, _currentUserRating, text);

                              setState(() {
                                if (club.userReview != null)
                                  club.userReview.review = text;
                                else
                                  club.userReview = ClubReview(
                                      null, _currentUserRating, text);
                              });

                              nearbyClubsCubit.updateUserReviewClub(club);
                              topClubsCubit.updateUserReviewClub(club);
                              favouriteClubsCubit.updateUserReviewClub(club);
                            }
                          },
                          style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18),
                          decoration: InputDecoration(
                            hintMaxLines: 3,
                            hintText:
                                "Your review will be submitted once you choose a rating & type something",
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

  Widget miniEventItem(Event event) {
    return FlatButton(
        onPressed: () {
          Navigator.pushNamed(context, '/event', arguments: event);
        },
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
                            DateFormat.MMM().format(event.eventStartDate),
                            style: TextStyle(
                              fontFamily: 'LatoBold',
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            DateFormat.d().format(event.eventStartDate),
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
                    event.title,
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
                        event.description,
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
        children: [
          SizedBox(
              height: 76,
              width: 76,
              child: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.5),
                backgroundImage: CachedNetworkImageProvider(
                    review.person.personProfilePicURL),
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
                  review.person.personUsername,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'LatoBold',
                      fontSize: 20,
                      color: Colors.white),
                ),
                RatingBar.builder(
                  initialRating: review.rating.toDouble(),
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
                      review.review,
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
  final String imageUrl;
  final Function onFavButtonClick;
  final bool isClubLiked;
  final double latitude;
  final double longitude;

  MySliverAppBar({
    @required this.expandedHeight,
    @required this.statusBarHeight,
    @required this.imageUrl,
    @required this.onFavButtonClick,
    @required this.isClubLiked,
    @required this.latitude,
    @required this.longitude,
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
                      child: CachedNetworkImage(
                    imageUrl: imageUrl,
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
                                    onPressed: () {
                                      MapsLauncher.launchCoordinates(
                                          latitude, longitude);
                                    },
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
                                              onPressed: () =>
                                                  onFavButtonClick(),
                                              child: Icon(
                                                isClubLiked
                                                    ? Icons.star_outlined
                                                    : Icons.star_border,
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
                                              padding: EdgeInsets.only(left: 8),
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
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
