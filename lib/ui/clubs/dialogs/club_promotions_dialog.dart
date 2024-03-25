import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/models/club_promotion.dart';
import 'package:intl/intl.dart';

class ClubPromotionsDialog extends StatelessWidget {
  final ClubPromotion? _clubPromotion;

  ClubPromotionsDialog(this._clubPromotion);

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: SimpleDialog(
        backgroundColor: Colors.purple,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Center(
            child: Column(
              children: [
                _topImageView(context),
                _bottomContentView(),
              ],
            ),
          ),
        ],
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
                  image: CachedNetworkImageProvider(_clubPromotion!.imageUrl!),
                  fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                _closeButton(context),
                _promotionsAlert(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _promotionsAlert() {
    return Align(
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
                    color: Colors.purple,
                    size: 18,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  Text(
                    "Available Until " +
                        DateFormat.MMMd()
                            .format(_clubPromotion!.promotionEndDate),
                    style: TextStyle(
                        color: Colors.purple,
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
    );
  }

  Widget _closeButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: 16, right: 16),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
              color: Colors.purple, borderRadius: BorderRadius.circular(9)),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
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
      child: _contentText(),
    );
  }

  Widget _contentText() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _clubPromotion!.title!,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              _clubPromotion!.description!,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.4)),
            ),
          ),
        ],
      ),
    );
  }
}
