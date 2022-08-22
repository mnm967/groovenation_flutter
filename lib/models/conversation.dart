import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 0)
class Conversation {
  @HiveField(0)
  String? conversationID;

  @HiveField(1)
  String? conversationPersonId;

  @HiveField(2)
  Map? latestMessageJSON;

  Message? latestMessage;

  SocialPerson? person;

  Conversation(this.conversationID, this.conversationPersonId,
      [this.latestMessage]) {
    if (latestMessage != null)
      latestMessageJSON = Message.toJson(latestMessage!);
  }

  factory Conversation.fromJson(dynamic json, [isListString = false]) {
    Conversation c = Conversation(
      json['conversationID'],
      json['conversationPersonId'],
      isListString
          ? Message.fromJson(jsonDecode(json['latestMessage']))
          : Message.fromJson(json['latestMessage']),
    );
    c.latestMessageJSON = Message.toJson(c.latestMessage!);

    return c;
  }

  factory Conversation.fromFireStore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print("Running: ");
    print("CID: " +
        Message.fromJson(jsonDecode(data['lastMessage']['content']))
            .conversationId!);

    return Conversation(
        doc.id,
        data['users'][0] == sharedPrefs.userId
            ? data['users'][1]
            : data['users'][0],
        Message.fromJson(jsonDecode(data['lastMessage']['content'])));
  }

  Map toJson() {
    return {
      "conversationID": conversationID,
      "conversationPersonId": "conversationPersonId",
      "latestMessage": Message.toJson(latestMessage!),
    };
  }
}
