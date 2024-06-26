import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationItem extends StatelessWidget {
  final Conversation? conversation;
  final SocialPerson? person;
  final Function? onClick;

  const ConversationItem({Key? key, this.conversation, this.person, this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Card(
        elevation: 4,
        color: Colors.deepPurple,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: TextButton(
          onPressed: () => onClick!(),
          child: Wrap(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _profileImage(),
                            _content(),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileImage() {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 64,
        width: 64,
        child: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.5),
          backgroundImage: CachedNetworkImageProvider(
              conversation!.person!.personProfilePicURL!),
        ),
      ),
    );
  }

  Widget _content() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _textContent(),
            _infoContent(),
          ],
        ),
      ),
    );
  }

  Widget _infoContent() {
    return Padding(
      padding: EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
              visible: conversation!.latestMessage!.sender!.personID ==
                  sharedPrefs.userId,
              child: Icon(Icons.check, color: Colors.white.withOpacity(0.4))),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4, right: 1),
              child: Text(
                (conversation!.latestMessage is TextMessage)
                    ? (conversation!.latestMessage as TextMessage).text!
                    : ((conversation!.latestMessage is MediaMessage)
                        ? (conversation!.latestMessage!.receiverId ==
                                sharedPrefs.userId
                            ? "Sent you an Image"
                            : "Sent an Image")
                        : (conversation!.latestMessage!.receiverId ==
                                sharedPrefs.userId
                            ? "Sent you a Post"
                            : "Sent a Post")),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 4, right: 3),
            child: Text(
              person!.personUsername!,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'LatoBold', fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 4),
          child: Text(
            "${timeago.format(conversation!.latestMessage!.messageDateTime!)}",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: 'LatoLight', fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
