import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:intl/intl.dart';

class EventCardView extends StatelessWidget {
  final Club? club;

  const EventCardView({Key? key, this.club}) : super(key: key);

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
                _emptyPrompt(),
                _cardList(),
                _viewMoreButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyPrompt() {
    return Visibility(
      visible: club!.upcomingEvents.length == 0,
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
            "Upcoming Events",
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
        itemCount: club!.upcomingEvents.length,
        itemBuilder: (context, index) {
          return _miniEventItem(context, club!.upcomingEvents[index]);
        });
  }

  Widget _viewMoreButton(BuildContext context) {
    return Visibility(
      visible: club!.upcomingEvents.length != 0,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(24),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/club_events', arguments: club);
        },
        child: Center(
          child: Text(
            "View More",
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontFamily: 'Lato'),
          ),
        ),
      ),
    );
  }

  Widget _miniEventDate(Event event) {
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniEventContent(Event event) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title!,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                event.description!,
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

  Widget _miniEventItem(BuildContext context, Event event) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/event', arguments: event);
      },
      style: TextButton.styleFrom(
         padding: EdgeInsets.only(top: 16, bottom: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _miniEventDate(event),
          _miniEventContent(event),
        ],
      ),
    );
  }
}
