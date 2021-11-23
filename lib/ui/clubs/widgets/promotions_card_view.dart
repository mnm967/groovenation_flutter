import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/club_promotion.dart';
import 'package:groovenation_flutter/ui/clubs/dialogs/club_promotions_dialog.dart';
import 'package:intl/intl.dart';

class PromotionsCardView extends StatelessWidget {
  final Club? club;

  const PromotionsCardView({Key? key, this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                _title(),
                _cardList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, top: 8, bottom: 16),
          child: Text(
            "Promotions",
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: 'Lato'),
          ),
        ),
      ],
    );
  }

  Widget _cardList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: club!.clubPromotions!.length,
      itemBuilder: (context, index) {
        return _miniPromotionItem(context, club!.clubPromotions![index]);
      },
    );
  }

  Widget _miniPromotionDate(ClubPromotion promotion) {
    return SizedBox(
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
                  DateFormat.MMM().format(promotion.promotionStartDate),
                  style: TextStyle(
                    fontFamily: 'LatoBold',
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat.d().format(promotion.promotionStartDate),
                  style: TextStyle(
                    fontFamily: 'LatoBold',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniPromotionContent(ClubPromotion promotion) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promotion.title!,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                promotion.description!,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClubPromotionDialog(BuildContext context, ClubPromotion promotion) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClubPromotionsDialog(promotion);
      },
    );
  }

  Widget _miniPromotionItem(BuildContext context, ClubPromotion promotion) {
    return FlatButton(
      onPressed: () => _showClubPromotionDialog(context, promotion),
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _miniPromotionDate(promotion),
          _miniPromotionContent(promotion),
        ],
      ),
    );
  }
}
