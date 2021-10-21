import 'dart:convert';

import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 0)
class Conversation {
  @HiveField(0)
  String conversationID;

  @HiveField(1)
  SocialPerson conversationPerson;

  @HiveField(2)
  int newMessagesCount;

  @HiveField(3)
  Map latestMessageJSON;

  Message latestMessage;

  Conversation(this.conversationID, this.conversationPerson,
      this.newMessagesCount, [this.latestMessage]) {
    if (latestMessage != null)
      latestMessageJSON = Message.toJson(latestMessage);
  }

  factory Conversation.fromJson(dynamic json, [isListString = false]) {
    Conversation c = Conversation(
      json['conversationID'],
      isListString
          ? SocialPerson.fromJson(jsonDecode(json['conversationPerson']))
          : SocialPerson.fromJson(json['conversationPerson']),
      json['newMessagesCount'],
      isListString
          ? Message.fromJson(jsonDecode(json['latestMessage']))
          : Message.fromJson(json['latestMessage']),
    );
    c.latestMessageJSON = Message.toJson(c.latestMessage);

    return c;
  }

  Map toJson() {
    return {
      "conversationID": conversationID,
      "conversationPerson": jsonEncode(conversationPerson),
      "newMessagesCount": newMessagesCount,
      "latestMessage": Message.toJson(latestMessage),
    };
  }
}
