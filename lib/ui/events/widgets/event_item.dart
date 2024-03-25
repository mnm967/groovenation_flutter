import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/event/events_cubit.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:intl/intl.dart';

class EventItem extends StatelessWidget {
  final Event? event;
  final bool? isFavourite;

  const EventItem({Key? key, this.event, this.isFavourite}) : super(key: key);

  void _changeFavourite(BuildContext context) {
    final FavouritesEventsCubit favouritesEventsCubit =
        BlocProvider.of<FavouritesEventsCubit>(context);
    if (isFavourite!) {
      favouritesEventsCubit.removeFavouriteEvent(event!);
    } else
      favouritesEventsCubit.addFavouriteEvent(event!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/event', arguments: event);
        },
        child: Wrap(
          children: [
            Column(
              children: [
                _mainContainer(context),
                _textContentBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainContainer(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            height: 256,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(event!.imageUrl!),
                  fit: BoxFit.cover),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 16, right: 16),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(9)),
                  child: TextButton(
                    onPressed: () => _changeFavourite(context),
                    child: Icon(
                      isFavourite! ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textContentBox() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _dateContainer(),
              Expanded(
                child: _textContainer(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _dateContainer() {
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
                  DateFormat.MMM().format(event!.eventStartDate),
                  style: TextStyle(
                    fontFamily: 'LatoBold',
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat.d().format(event!.eventStartDate),
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

  Widget _textContainer() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event!.title!,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              event!.clubName!,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
