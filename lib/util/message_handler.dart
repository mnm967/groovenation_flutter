import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/util/hive_box_provider.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MessageHandler {
  static Message _getMessageFromJSON(data) {
    switch (data["messageType"]) {
      case MESSAGE_TYPE_MEDIA:
        return MediaMessage.fromJson(jsonDecode(data["message"]));
        break;
      case MESSAGE_TYPE_POST:
        return SocialPostMessage.fromJson(jsonDecode(data["message"]));
        break;
      default:
        return TextMessage.fromJson(jsonDecode(data["message"]));
        break;
    }
  }

  static Future _addMessageConversation(var data, Message newMessage) async {
    Conversation conversation =
        Conversation.fromJson(jsonDecode(data['conversation']));

    newMessage.conversationId = conversation.conversationID;

    var box = await Hive.openBox<Conversation>('conversation');
    var sbox = await Hive.openBox<SavedMessage>('savedmessage');

    sbox.add(
        SavedMessage(newMessage.conversationId, Message.toJson(newMessage)));

    box.add(conversation);
  }

  static Future _updateMessageConversation(var data, Message newMessage) async {
    String? conversationId = newMessage.conversationId;

    var box = await Hive.openBox<Conversation>('conversation');
    var m = await Hive.openBox<SavedMessage>('savedmessage');

    m.add(SavedMessage(conversationId, jsonDecode(data["message"])));

    List<Conversation> conversations = box.values.toList();

    int index = conversations
        .indexWhere((element) => element.conversationID == conversationId);

    if (index != -1) {
      Conversation c = conversations[index];

      c.newMessagesCount = c.newMessagesCount! + 1;

      c.latestMessage = newMessage;
      c.latestMessageJSON = Message.toJson(newMessage);

      conversations[index] = c;

      box.putAt(index, c);
    }
  }

  static Future _sendNotification(Message newMessage) async {
    String? text;

    switch (newMessage.messageType) {
      case MESSAGE_TYPE_MEDIA:
        text = "Sent you an Image";
        break;
      case MESSAGE_TYPE_POST:
        text = "Sent you a Post";
        break;
      default:
        text = (newMessage as TextMessage).text;
        break;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: newMessage.messageID.hashCode,
          channelKey: 'groovenation_channel',
          title: "Message from ${newMessage.sender!.personUsername}",
          body: text,
          largeIcon: newMessage.sender!.personProfilePicURL,
          backgroundColor: Colors.deepPurple,
          color: Colors.white,
          notificationLayout: NotificationLayout.Messaging,
          summary: "New Message"),
    );
  }

  static void handleMessage(var data) async {
    Message newMessage = _getMessageFromJSON(data);

    await HiveBoxProvider.init();

    if (data["command"] == "add_message_conversation")
      await _addMessageConversation(data, newMessage);
    else
      await _updateMessageConversation(data, newMessage);

    if (!sharedPrefs.mutedConversations.contains(newMessage.conversationId))
      _sendNotification(newMessage);
  }
}
