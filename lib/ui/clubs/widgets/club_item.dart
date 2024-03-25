import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ClubItem extends StatelessWidget {
  final Club? club;
  final bool? isFavourite;
  final Function? onClubSelected;

  const ClubItem({Key? key, this.club, this.isFavourite, this.onClubSelected})
      : super(key: key);

  void _changeClubFavourite(BuildContext context) {
    final FavouritesClubsCubit _favouritesClubsCubit =
        BlocProvider.of<FavouritesClubsCubit>(context);

    if (isFavourite!) {
      _favouritesClubsCubit.removeFavouriteClub(club!);
    } else
      _favouritesClubsCubit.addFavouriteClub(club!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      child: TextButton(
        onPressed: onClubSelected == null
            ? () {
                Navigator.pushNamed(context, '/club', arguments: club);
              }
            : () {
                onClubSelected!(club!.clubID, club!.name);
                Navigator.pop(context);
              },
        child: Wrap(
          children: [
            Column(
              children: [
                _topImageView(context),
                _bottomContentView(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topImageView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            height: 236,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(club!.images[0]),
                  fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                _favouriteButton(context),
                _promotionsAlert(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _promotionsAlert() {
    return Visibility(
      visible:
          (club!.clubPromotions != null && club!.clubPromotions!.isNotEmpty),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 16, left: 16),
          child: Wrap(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(900)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.dollarSign,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                    ),
                    Text(
                      "Promotions Available",
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontFamily: 'LatoBold',
                          fontSize: 14),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favouriteButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: 16, right: 16),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
              color: Colors.deepPurple, borderRadius: BorderRadius.circular(9)),
          child: TextButton(
            onPressed: () => _changeClubFavourite(context),
            child: Icon(
              isFavourite! ? Icons.star : Icons.star_border,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomContentView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _contentClubRating(),
              Expanded(
                child: _contentText(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _contentClubRating() {
    return SizedBox(
      height: 84,
      width: 84,
      child: CircularPercentIndicator(
        radius: 79,
        circularStrokeCap: CircularStrokeCap.round,
        lineWidth: 5.0,
        percent: club!.averageRating! / 5.0,
        center: new Text(
          club!.averageRating!.toDouble().toStringAsFixed(1),
          style: TextStyle(
              fontFamily: 'LatoBold', color: Colors.white, fontSize: 24),
        ),
        progressColor: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  Widget _contentText() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            club!.name!,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
                fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              "Johannesburg",
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.4)),
            ),
          ),
        ],
      ),
    );
  }
}
