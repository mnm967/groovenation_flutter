import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:intl/intl.dart';

class TicketItem extends StatelessWidget {
  final Ticket? ticket;
  final bool? isCompleted;
  final Function? onTicketPressed;

  const TicketItem(
      {Key? key, this.ticket, this.isCompleted, this.onTicketPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: TextButton(
        onPressed: () => onTicketPressed!(context, ticket),
        child: Wrap(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _imageContainer(),
                          Expanded(child: _contentContainer())
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageContainer() {
    return SizedBox(
      height: 164,
      width: 128,
      child: Stack(
        children: [
          Image(
            height: double.infinity,
            width: 128,
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(ticket!.imageUrl!),
          ),
          Container(
            color: Colors.black.withOpacity(0.25),
            child: Center(
              child: new FaIcon(
                isCompleted!
                    ? FontAwesomeIcons.checkCircle
                    : FontAwesomeIcons.qrcode,
                size: 72,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _contentContainer() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ticket!.eventName!,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
                fontFamily: 'LatoBold',
                fontSize: 18,
                decoration: isCompleted!
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.zero,
            child: Text(
              ticket!.clubName!,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              DateFormat("MMM dd, yyyy · HH:mm").format(ticket!.startDate!),
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                  fontFamily: 'Lato', fontSize: 16, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              "• " + ticket!.ticketType!,
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                  fontFamily: 'Lato', fontSize: 16, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              ticket!.noOfPeople! > 1
                  ? "•  " + ticket!.noOfPeople.toString() + " People"
                  : "•  1 Person",
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                  fontFamily: 'Lato', fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
