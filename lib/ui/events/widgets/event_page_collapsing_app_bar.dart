import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventCollapsingAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double statusBarHeight;
  final String? imageUrl;
  final Function onTicketButtonClick;
  final Function onClubButtonClick;
  final Function onFavButtonClick;
  final bool isEventLiked;
  final bool showClubButton;
  final bool showTicketButton;

  EventCollapsingAppBar({
    required this.expandedHeight,
    required this.statusBarHeight,
    required this.imageUrl,
    required this.onTicketButtonClick,
    required this.onClubButtonClick,
    required this.onFavButtonClick,
    required this.isEventLiked,
    required this.showClubButton,
    required this.showTicketButton,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: expandedHeight,
      child: Stack(
        children: [
          _appBarContainer(context, shrinkOffset),
          _actionButtonsContainer(context, shrinkOffset),
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
              imageUrl: imageUrl!,
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
                                _likeButton(shrinkOffset),
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

  Widget _likeButton(double shrinkOffset) {
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
                isEventLiked ? Icons.favorite_outlined : Icons.favorite_border,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
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
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(90),
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

  Widget _actionButtonsContainer(BuildContext context, double shrinkOffset) {
    return Container(
      height: (expandedHeight),
      width: double.infinity,
      child: Opacity(
        opacity: (1 - shrinkOffset / expandedHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _zoomButton(context),
            showTicketButton ? _ticketButton() : Container(),
            showClubButton ? _clubButton() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _clubButton() {
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
              onPressed: onClubButtonClick as void Function()?,
              child: Center(
                child: Icon(
                  Icons.local_bar,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _zoomButton(BuildContext context) {
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
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => ImageDialog(
                    imageUrl: imageUrl!,
                  ),
                );
              },
              child: Center(
                child: Icon(
                  FontAwesomeIcons.eye,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticketButton() {
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
              onPressed: onTicketButtonClick as void Function()?,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.ticketAlt,
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
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class ImageDialog extends StatelessWidget {
  final String imageUrl;

  const ImageDialog({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
