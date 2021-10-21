import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:hive/hive.dart';

class ChatRepository {
Future<dynamic> sendMessage(Message message) async {
    var uid = sharedPrefs.userId;

    try {
      Response response = await Dio().post("$API_HOST/chat/message/send",
          data: {
            "message": jsonEncode(Message.toJson(message)),
            "userId": uid
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(jsonResponse);

        if (jsonResponse['status'] == 1) {
          return true;
        } else if (jsonResponse['status'] == 2) {
          Conversation conversation =
              Conversation.fromJson(jsonResponse['conversation']);
          return conversation;
        } else
          throw ChatException(Error.UNKNOWN_ERROR);
      } else
        throw ChatException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ChatException)
        throw ChatException(e.error);
      else
        throw ChatException(Error.NETWORK_ERROR);
    }
  }

  Future<List<Conversation>> getConversations() async {
    var uid = sharedPrefs.userId;
    List<Conversation> conversations = [];

    try {
      Response response = await Dio().get("$API_HOST/chat/conversations/$uid");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(jsonResponse);

        if (jsonResponse['status'] == 1) {
          for (Map i in jsonResponse['conversations']) {
            Conversation conversation = Conversation.fromJson(i);
            conversations.add(conversation);
          }

          var box = await Hive.openBox<Conversation>('conversation');
          await box.clear();
          box.addAll(conversations);

          conversations.sort((a, b) => b.latestMessage.messageDateTime
              .compareTo(a.latestMessage.messageDateTime));

          sharedPrefs.isUserConversationsLoaded = true;

          return conversations;
        } else
          throw ChatException(Error.UNKNOWN_ERROR);
      } else
        throw ChatException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ChatException)
        throw ChatException(e.error);
      else
        throw ChatException(Error.NETWORK_ERROR);
    }
  }

  Future<void> setMessagesRead(String conversationId) async {
    var uid = sharedPrefs.userId;
    try {
      Response response = await Dio()
          .get("$API_HOST/chat/conversations/read/$conversationId/$uid");
      if (response.statusCode == 200) {
      } else
        throw ChatException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ChatException)
        throw ChatException(e.error);
      else
        throw ChatException(Error.NETWORK_ERROR);
    }
  }

  Future<void> getMessages() async {
    var uid = sharedPrefs.userId;

    try {
      Response response = await Dio().get("$API_HOST/chat/messages/$uid");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          List<SavedMessage> messages = [];

          for (Map i in jsonResponse['messages']) {
            Message message = Message.fromJson(i);
            messages.add(SavedMessage(message.conversationId, i));
          }

          var box = await Hive.openBox<SavedMessage>('savedmessage');
          await box.clear();
          box.addAll(messages);

          sharedPrefs.isUserMessagesLoaded = true;
        } else
          throw ChatException(Error.UNKNOWN_ERROR);
      } else
        throw ChatException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ChatException)
        throw ChatException(e.error);
      else
        throw ChatException(Error.NETWORK_ERROR);
    }
  }
}

class ChatException implements Exception {
  final Error error;
  ChatException(this.error);
}
