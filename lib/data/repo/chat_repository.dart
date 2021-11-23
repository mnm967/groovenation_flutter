import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/util/network_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive/hive.dart';

class ChatRepository {
  Future<dynamic> sendMessage(Message message) async {
    var uid = sharedPrefs.userId;
    String url = "$API_HOST/chat/message/send";
    var body = {"message": jsonEncode(Message.toJson(message)), "userId": uid};

    var jsonResponse =
        await NetworkUtil.executePostRequest(url, body, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['status'] == 1) {
        return true;
      } else if (jsonResponse['status'] == 2) {
        Conversation conversation =
            Conversation.fromJson(jsonResponse['conversation']);
        return conversation;
      }
    }
  }

  Future<List<Conversation>?> getConversations() async {
    var uid = sharedPrefs.userId;
    List<Conversation> conversations = [];

    String url = "$API_HOST/chat/conversations/$uid";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['status'] == 1) {
        for (Map i in jsonResponse['conversations']) {
          Conversation conversation = Conversation.fromJson(i);
          conversations.add(conversation);
        }

        var box = await Hive.openBox<Conversation>('conversation');
        await box.clear();
        box.addAll(conversations);

        conversations.sort((a, b) => b.latestMessage!.messageDateTime!
            .compareTo(a.latestMessage!.messageDateTime!));

        sharedPrefs.isUserConversationsLoaded = true;

        return conversations;
      }
    }

    return null;
  }

  Future<void> setMessagesRead(String conversationId) async {
    var uid = sharedPrefs.userId;

    String url = "$API_HOST/chat/conversations/read/$conversationId/$uid";
    await NetworkUtil.executeGetRequest(url, _onRequestError);
  }

  Future<void> getMessages() async {
    var uid = sharedPrefs.userId;

    String url = "$API_HOST/chat/messages/$uid";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
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
      }
    }
  }

  _onRequestError(e) {
    if (e is ChatException)
      throw ChatException(e.error);
    else if (e is DioError) if (e.type != DioErrorType.cancel)
      throw ChatException(AppError.NETWORK_ERROR);
    else
      throw ChatException(AppError.UNKNOWN_ERROR);
  }
}

class ChatException implements Exception {
  final AppError error;
  ChatException(this.error);
}