import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/club/club_reviews_cubit.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/club_promotion.dart';
import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/ui/clubs/dialogs/club_promotions_dialog.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/club_page_collapsing_toolbar.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/event_card_view.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/images_card_view.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/moments_card_view.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/promotions_card_view.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/review_card_view.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubPage extends StatefulWidget {
  final Club? club;
  ClubPage(this.club);

  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  ScrollController _scrollController = new ScrollController();
  FavouritesClubsCubit? favouritesClubsCubit;

  Club? club;

  void _launchURL(String url) async {
    if (await canLaunch(url))
      await launch(url);
    else
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, CANNOT_LAUNCH_URL_PROMPT, Colors.red, Icons.error);
  }

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> _sendAnalyticsEvent() async {
    analytics.logEvent(name: "club_view", parameters: <String, dynamic>{
      "club_id": club!.clubID,
      "club_name": club!.name,
    });
  }

  @override
  void initState() {
    super.initState();
    club = widget.club;

    favouritesClubsCubit = BlocProvider.of<FavouritesClubsCubit>(context);

    if (club!.userReview != null)
      _currentUserRating = club!.userReview!.rating!.toDouble();
    if (club!.userReview != null) _currentUserReview = club!.userReview!.review;

    _sendAnalyticsEvent();
  }

  Widget _collapsingAppBar() {
    final FavouritesClubsCubit favouritesClubsCubit =
        BlocProvider.of<FavouritesClubsCubit>(context);

    return SliverPersistentHeader(
      delegate: ClubCollapsingAppBar(
          expandedHeight: 392.0,
          statusBarHeight: MediaQuery.of(context).padding.top,
          imageUrl: club!.images[0],
          clubID: club!.clubID,
          onFavButtonClick: () {
            if (favouritesClubsCubit.checkClubExists(club!.clubID)) {
              favouritesClubsCubit.removeFavouriteClub(club!);
            } else
              favouritesClubsCubit.addFavouriteClub(club!);
          },
          latitude: club!.latitude,
          longitude: club!.longitude),
      floating: false,
      pinned: true,
    );
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
              _collapsingAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _clubName(),
                      _ratingBar(),
                      _socialButtons(),
                      _cardView(FontAwesomeIcons.mapMarkerAlt, club!.address!),
                      (club!.phoneNumber != null && club!.phoneNumber!.isNotEmpty)
                          ? _cardView(
                              FontAwesomeIcons.mobile, club!.phoneNumber!)
                          : Padding(padding: EdgeInsets.zero),
                      (club!.webLink != null && club!.webLink!.isNotEmpty)
                          ? _cardView(
                              FontAwesomeIcons.globeAfrica, club!.webLink!)
                          : Padding(padding: EdgeInsets.zero),
                      (club!.clubPromotions != null &&
                              club!.clubPromotions!.isNotEmpty)
                          ? PromotionsCardView(club: club)
                          : Container(),
                      EventCardView(
                        club: club,
                      ),
                      ImagesCardView(club: club),
                      MomentsCardView(club: club),
                      ReviewCardView(club: club),
                      Padding(
                        padding: EdgeInsets.only(bottom: 36),
                        child: _userReviewCardView(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _ratingBar() {
    return RatingBar.builder(
      initialRating: club!.averageRating!.toDouble(),
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
    );
  }

  Widget _clubName() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(
        club!.name!,
        style: TextStyle(
            color: Colors.white, fontSize: 28, fontFamily: 'LatoBold'),
      ),
    );
  }

  Widget _socialButton(IconData icon, String? link) {
    return Visibility(
      visible: link != null && link.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: RawMaterialButton(
          onPressed: () {
            _launchURL(link!);
          },
          constraints: BoxConstraints.expand(width: 64, height: 64),
          elevation: 0,
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          padding: EdgeInsets.all(16.0),
          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _socialButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _socialButton(FontAwesomeIcons.globeAfrica, club!.webLink),
          _socialButton(FontAwesomeIcons.facebookF, club!.facebookLink),
          _socialButton(FontAwesomeIcons.twitter, club!.twitterLink),
          _socialButton(FontAwesomeIcons.instagram, club!.instagramLink),
        ],
      ),
    );
  }

  double _currentUserRating = 0.0;
  String? _currentUserReview = "";
  TextEditingController _reviewInputController = TextEditingController();

  //TODO: Optimize
  void _onUserReviewChanged(text) {
    setState(() {
      _currentUserReview = text;
    });

    final NearbyClubsCubit nearbyClubsCubit =
        BlocProvider.of<NearbyClubsCubit>(context);
    final TopClubsCubit topClubsCubit = BlocProvider.of<TopClubsCubit>(context);
    final FavouritesClubsCubit favouriteClubsCubit =
        BlocProvider.of<FavouritesClubsCubit>(context);

    if (text.isNotEmpty && _currentUserRating > 0) {
      num? newClubRating = club!.averageRating;

      if (club!.userReview != null &&
          _currentUserRating != club!.userReview!.rating) {
        num tave = club!.averageRating! * club!.totalReviews!;
        tave = tave - club!.userReview!.rating!;
        tave = tave + _currentUserRating;
        newClubRating = tave / club!.totalReviews!;
      } else {
        num tave = club!.averageRating! * club!.totalReviews!;
        setState(() {
          club!.totalReviews = club!.totalReviews! + 1;
        });
        tave = tave + _currentUserRating;
        newClubRating = tave / club!.totalReviews!;
      }

      setState(() {
        club!.averageRating = newClubRating!.toDouble();
      });

      final AddClubReviewCubit addClubReviewCubit =
          BlocProvider.of<AddClubReviewCubit>(context);

      addClubReviewCubit.addReview(club!.clubID, _currentUserRating, text);

      setState(() {
        if (club!.userReview != null)
          club!.userReview!.review = text;
        else
          club!.userReview = ClubReview(null, _currentUserRating, text);
      });

      nearbyClubsCubit.updateUserReviewClub(club);
      topClubsCubit.updateUserReviewClub(club);
      favouriteClubsCubit.updateUserReviewClub(club);
    }
  }

  //TODO: Optimize
  void _onUserRatingBarChanged(rating) {
    setState(() {
      _currentUserRating = rating;
    });

    final NearbyClubsCubit nearbyClubsCubit =
        BlocProvider.of<NearbyClubsCubit>(context);
    final TopClubsCubit topClubsCubit = BlocProvider.of<TopClubsCubit>(context);
    final FavouritesClubsCubit favouriteClubsCubit =
        BlocProvider.of<FavouritesClubsCubit>(context);

    if (_reviewInputController.text.isNotEmpty && _currentUserRating > 0) {
      num? newClubRating = club!.averageRating;

      if (club!.userReview != null) {
        num tave = club!.averageRating! * club!.totalReviews!;
        tave = tave - club!.userReview!.rating!;
        tave = tave + rating;
        newClubRating = tave / club!.totalReviews!;
      } else {
        num tave = club!.averageRating! * club!.totalReviews!;
        setState(() {
          club!.totalReviews = club!.totalReviews! + 1;
        });
        tave = tave + rating;
        newClubRating = tave / club!.totalReviews!;
      }

      setState(() {
        club!.averageRating = newClubRating!.toDouble();
        if (club!.userReview != null) club!.userReview!.rating = rating;
      });

      final AddClubReviewCubit addClubReviewCubit =
          BlocProvider.of<AddClubReviewCubit>(context);

      addClubReviewCubit.addReview(
          club!.clubID, _currentUserRating, _reviewInputController.text);

      if (club!.userReview != null) {
        nearbyClubsCubit.updateUserReviewClub(club);
        topClubsCubit.updateUserReviewClub(club);
        favouriteClubsCubit.updateUserReviewClub(club);
      }
    }
  }

  Widget _userReviewCardTitle() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, top: 8, bottom: 24),
          child: Text(
            "Leave a Review",
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: 'Lato'),
          ),
        ),
      ],
    );
  }

  Widget _userReviewCardTextField() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _reviewInputController,
        maxLength: 1000,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        cursorColor: Colors.white.withOpacity(0.7),
        onChanged: (text) => _onUserReviewChanged(text),
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
              borderSide:
                  const BorderSide(color: Color(0xffE65AB9), width: 1.0)),
        ),
      ),
    );
  }

  Widget _userReviewCardRatingBar() {
    return RatingBar.builder(
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
      onRatingUpdate: (rating) => _onUserRatingBarChanged(rating),
    );
  }

  Widget _userReviewCardView() {
    _reviewInputController.value = TextEditingValue(
      text: _currentUserReview!,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _currentUserReview!.length),
      ),
    );

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
                  _userReviewCardTitle(),
                  _userReviewCardRatingBar(),
                  _userReviewCardTextField(),
                ],
              )),
        ),
      ),
    );
  }

  Widget _cardView(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        child: Card(
          color: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: _cardViewContent(icon, text),
        ),
      ),
    );
  }

  Widget _cardViewContent(IconData icon, String text) {
    return FlatButton(
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
                    color: Colors.white, fontSize: 18, fontFamily: 'Lato'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
