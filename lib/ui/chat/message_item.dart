import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/ui/social/widgets/social_item.dart';
import 'package:intl/intl.dart';

class MessageItem extends StatelessWidget {
  final bool? isRight;
  final Message? message;

  const MessageItem({Key? key, this.isRight, this.message}) : super(key: key);

  void _showMessageOptions() {
    //TODO: Implement Method
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment:
            isRight! ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Wrap(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ((MediaQuery.of(context).size.width * 0.80)),
                ),
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: isRight! ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(9)),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onLongPress: () {
                        _showMessageOptions();
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            message!.messageType == MESSAGE_TYPE_TEXT
                                ? _messageText(isRight!, message!)
                                : Container(),
                            message!.messageType == MESSAGE_TYPE_MEDIA
                                ? _messageMedia(isRight, message!)
                                : Container(),
                            message!.messageType == MESSAGE_TYPE_POST
                                ? _messageSocial(isRight, message!)
                                : Container(),
                            _messageDate(isRight!, message!)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageDate(bool isRight, Message message) {
    return Padding(
      padding: EdgeInsets.only(right: 4, bottom: 4, left: 4),
      child: Text(
        DateFormat('yyyy/MM/dd, kk:mm')
            .format(message.messageDateTime!.toLocal()),
        style: TextStyle(
          color: isRight
              ? Colors.white.withOpacity(0.7)
              : Colors.deepPurple.withOpacity(0.8),
          fontFamily: 'Lato',
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _messageSocial(bool? isRight, Message message) {
    return SocialItem(
      socialPost: (message as SocialPostMessage).post,
      showClose: false,
      key: Key(message.post!.postID!),
      removeElevation: true,
    );
  }

  Widget _messageMedia(bool? isRight, Message message) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 1,
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: CachedNetworkImage(
            imageUrl: (message as MediaMessage).mediaURL!,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _messageText(bool isRight, Message message) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        (message as TextMessage).text!,
        textAlign: isRight ? TextAlign.end : TextAlign.start,
        style: TextStyle(
            color: isRight ? Colors.white : Colors.deepPurple,
            fontFamily: 'Lato',
            fontSize: 16),
      ),
    );
  }
}
