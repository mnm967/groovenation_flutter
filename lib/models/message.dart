import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String? messageID;

  @HiveField(1)
  String? conversationId;

  @HiveField(3)
  final String? messageType;

  @HiveField(4)
  final DateTime? messageDateTime;

  @HiveField(5)
  final SocialPerson? sender;

  @HiveField(6)
  final String? receiverId;
  
  @HiveField(7)
  String? messageStatus;

  Message(this.messageID, this.conversationId, this.messageType,
      this.messageDateTime, this.sender, this.receiverId, [this.messageStatus = MESSAGE_STATUS_PENDING]);

  factory Message.fromJson(dynamic json) {
    switch (json['messageType']) {
      case MESSAGE_TYPE_TEXT:
        return TextMessage.fromJson(json);
      case MESSAGE_TYPE_MEDIA:
        return MediaMessage.fromJson(json);
      case MESSAGE_TYPE_POST:
        return SocialPostMessage.fromJson(json);
      default:
        return TextMessage.fromJson(json);
    }
  }

  static Map toJson(Message m) {
    if(m.messageType == MESSAGE_TYPE_MEDIA) return MediaMessage.getJson(m as MediaMessage); 
    else if(m.messageType == MESSAGE_TYPE_POST) return SocialPostMessage.getJson(m as SocialPostMessage);
    else return TextMessage.getJson(m as TextMessage);
  }
}

@HiveType(typeId: 3)
class TextMessage extends Message {
  @HiveField(8)
  final String? text;

  TextMessage(String? messageID, String? conversationId, DateTime? messageDateTime,
      SocialPerson? sender, this.text, String? receiverId)
      : super(messageID, conversationId, MESSAGE_TYPE_TEXT, messageDateTime,
            sender, receiverId);

  factory TextMessage.fromJson(dynamic json) {
    return TextMessage(
        json['messageId'],
        json['conversationId'],
        DateTime.parse(json['messageDateTime']),
        SocialPerson.fromJson(json['sender']),
        json['text'],
        json['receiverId']);
  }

  static Map getJson(TextMessage message) {
    return {
      "messageId" : message.messageID,
      "conversationId" : message.conversationId,
      "messageType" : message.messageType,
      "messageDateTime" : message.messageDateTime!.toIso8601String(),
      "sender" : message.sender!.toJson(),
      "text" : message.text,
      "receiverId" : message.receiverId,
    };
  }
}

@HiveType(typeId: 4)
class MediaMessage extends Message {
  @HiveField(8)
  final String? mediaURL;

  MediaMessage(
      String? messageID,
      String? conversationId,
      DateTime? messageDateTime,
      SocialPerson? sender,
      this.mediaURL,
      String? receiverId, [String? messageStatus])
      : super(messageID, conversationId, MESSAGE_TYPE_MEDIA, messageDateTime,
            sender, receiverId, messageStatus);

  factory MediaMessage.fromJson(dynamic json) {
    return MediaMessage(
        json['messageId'],
        json['conversationId'],
        DateTime.parse(json['messageDateTime']),
        SocialPerson.fromJson(json['sender']),
        json['mediaURL'],
        json['receiverId']);
  }

  static Map getJson(MediaMessage message) {
    return {
      "messageId" : message.messageID,
      "conversationId" : message.conversationId,
      "messageType" : message.messageType,
      "messageDateTime" : message.messageDateTime!.toIso8601String(),
      "sender" : message.sender!.toJson(),
      "mediaURL" : message.mediaURL,
      "receiverId" : message.receiverId,
    };
  }
}

@HiveType(typeId: 5)
class SocialPostMessage extends Message {
  @HiveField(8)
  final SocialPost? post;

  SocialPostMessage(
      String? messageID,
      String? conversationId,
      DateTime? messageDateTime,
      SocialPerson? sender,
      this.post,
      String? receiverId)
      : super(messageID, conversationId, MESSAGE_TYPE_POST, messageDateTime,
            sender, receiverId);

  factory SocialPostMessage.fromJson(dynamic json) {
    return SocialPostMessage(
        json['messageId'],
        json['conversationId'],
        DateTime.parse(json['messageDateTime']),
        SocialPerson.fromJson(json['sender']),
        SocialPost.fromJson(json['post']),
        json['receiverId']);
  }

  static Map getJson(SocialPostMessage message) {
    return {
      "messageId" : message.messageID,
      "conversationId" : message.conversationId,
      "messageType" : message.messageType,
      "messageDateTime" : message.messageDateTime!.toIso8601String(),
      "sender" : message.sender!.toJson(),
      "post" : message.post!.toJson(),
      "receiverId" : message.receiverId,
    };
  }
}
