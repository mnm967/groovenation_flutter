import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:maps_launcher/maps_launcher.dart';

class ClubCollapsingAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double statusBarHeight;
  final String imageUrl;
  final Function onFavButtonClick;
  final double? latitude;
  final double? longitude;
  final String? clubID;

  ClubCollapsingAppBar({
    required this.expandedHeight,
    required this.statusBarHeight,
    required this.imageUrl,
    required this.onFavButtonClick,
    required this.latitude,
    required this.longitude,
    required this.clubID,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: expandedHeight,
      child: Stack(
        children: [
          _appBarContainer(context, shrinkOffset),
          _actionButtonsContainer(shrinkOffset),
        ],
      ),
    );
  }

  Widget _appBarContainer(BuildContext context, double shrinkOffset) {
    return Container(
      height: (expandedHeight - 36),
      child: Stack(
        fit: StackFit.expand,
        overflow: Overflow.visible,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: _appBar(context, shrinkOffset),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context, double shrinkOffset) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 16, left: 16, right: 0, bottom: 0),
                        child: Container(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: double.infinity,
                            height: expandedHeight,
                            child: Stack(
                              children: [
                                _favouriteButton(shrinkOffset),
                                _backButton(context, shrinkOffset),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _favouriteButton(double shrinkOffset) {
    return BlocBuilder<FavouritesClubsCubit, ClubsState>(
      builder: (context, favouriteEventsState) {
        final FavouritesClubsCubit favouritesClubsCubit =
            BlocProvider.of<FavouritesClubsCubit>(context);
        return Opacity(
          opacity: (1 - shrinkOffset / expandedHeight),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 16, right: 16),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => onFavButtonClick(),
                  child: Icon(
                    favouritesClubsCubit.checkClubExists(clubID)
                        ? Icons.star_outlined
                        : Icons.star_border,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _backButton(BuildContext context, double shrinkOffset) {
    return Opacity(
      opacity: (1 - shrinkOffset / expandedHeight),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 16, right: 16),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(900),
            ),
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
          ),
        ),
      ),
    );
  }

  Widget _actionButtonsContainer(double shrinkOffset) {
    return Container(
      height: (expandedHeight),
      width: double.infinity,
      child: Opacity(
        opacity: (1 - shrinkOffset / expandedHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _mapButton(),
          ],
        ),
      ),
    );
  }

  Widget _mapButton() {
    return Padding(
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
                MapsLauncher.launchCoordinates(latitude!, longitude!);
              },
              child: Center(
                child: Icon(
                  FontAwesomeIcons.mapMarkedAlt,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => statusBarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
