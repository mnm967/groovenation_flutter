import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';

class Message {
  final String messageID;
  final DateTime messageDateTime;
  final SocialPerson sender;

  Message(this.messageID, this.messageDateTime, this.sender);
}

class TextMessage extends Message {
  final String text;

  TextMessage(String messageID, DateTime messageDateTime, SocialPerson sender, this.text)
      : super(messageID, messageDateTime, sender);
}

class MediaMessage extends Message {
  final String mediaURL;

  MediaMessage(String messageID, DateTime messageDateTime, SocialPerson sender, this.mediaURL)
      : super(messageID, messageDateTime, sender);
}

class SocialPostMessage extends Message {
  final SocialPost post;

  SocialPostMessage(String messageID, DateTime messageDateTime, SocialPerson sender, this.post)
      : super(messageID, messageDateTime, sender);
}
