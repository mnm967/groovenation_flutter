import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/chat/chat_cubit.dart';
import 'package:groovenation_flutter/cubit/state/chat_state.dart';
import 'package:groovenation_flutter/data/repo/chat_repository.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ConversationsCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;

  late ChatCubit chatCubit;

  ConversationsCubit(this.chatRepository) : super(ConversationsInitialState());

  bool isChatLoadedState() {
    return state is ChatLoadedState;
  }

  bool isFirstConnection = true;

  void getConversations() async {
    var box = await Hive.openBox<Conversation>('conversation');
    if (box.values.isNotEmpty) {
      List<Conversation> list = box.values.toList();

      list.forEach((element) {
        element.latestMessage = Message.fromJson(element.latestMessageJSON);
      });

      list.sort((a, b) => b.latestMessage!.messageDateTime!
          .compareTo(a.latestMessage!.messageDateTime!));

      emit(ConversationsLoadedState(conversations: list));
    }
  }

  void _fetchConversations() async {
    try {
      chatRepository.getConversations().then((conversations) =>
          {emit(ConversationsLoadedState(conversations: conversations))});
    } on ChatException catch (_) {
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
    }
  }

  void init(context) async {
    chatCubit = BlocProvider.of<ChatCubit>(context);

    if (sharedPrefs.isUserConversationsLoaded) {
      _loadLatestMessages();
    } else {
      _fetchConversations();
    }

    if (!sharedPrefs.isUserMessagesLoaded) {
      try {
        chatRepository.getMessages();
      } on ChatException catch (_) {
        alertUtil.sendAlert(
            BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
      }
    }
  }

  void _loadLatestMessages() async {
    var box = await Hive.openBox<Conversation>('conversation');
    if (box.values.isNotEmpty) {
      List<Conversation> list = box.values.toList();

      list.forEach((element) {
        element.latestMessage = Message.fromJson(element.latestMessageJSON);
      });

      list.sort((a, b) => b.latestMessage!.messageDateTime!
          .compareTo(a.latestMessage!.messageDateTime!));

      emit(ConversationsLoadedState(conversations: list));
    }
  }

  void setMessagesRead(String? conversationId) async {
    if (conversationId == null) return;

    messagesRead(conversationId);

    try {
      chatRepository.setMessagesRead(conversationId);
    } on ChatException catch (e) {
      print(e.error.toString());
    }
  }

  void messagesRead(String conversationId) async {
    var box = await Hive.openBox<Conversation>('conversation');

    List<Conversation> conversations = box.values.toList();

    int index = conversations
        .indexWhere((element) => element.conversationID == conversationId);

    if (index != -1) {
      Conversation c = conversations[index];

      c.newMessagesCount = c.newMessagesCount = 0;

      conversations[index] = c;

      box.putAt(index, c);
    }

    if (state is ConversationsLoadedState) {
      conversations.sort((a, b) => b.latestMessage!.messageDateTime!
          .compareTo(a.latestMessage!.messageDateTime!));

      emit(ConversationsUpdatingState());
      emit(ConversationsLoadedState(conversations: conversations));
    }
  }

  Future<Conversation?> getPersonConversation(String? personId) async {
    var box = await Hive.openBox<Conversation>('conversation');
    if (box.values.isNotEmpty) {
      List<Conversation> conversation = box.values.toList();

      return conversation.firstWhereOrNull(
          (element) => element.conversationPerson!.personID == personId);
    } else
      return null;
  }

  void updateSocialPersonIfExists(SocialPerson person) async {
    var box = await Hive.openBox<Conversation>('conversation');

    List<Conversation> conversations = box.values.toList();

    int index = conversations.indexWhere(
        (element) => element.conversationPerson!.personID == person.personID);

    if (conversations.isEmpty || index == -1) return;

    Conversation c = conversations[index];
    c.conversationPerson = person;

    box.putAt(index, c);

    if (state is ConversationsLoadedState) {
      conversations.sort((a, b) => b.latestMessage!.messageDateTime!
          .compareTo(a.latestMessage!.messageDateTime!));

      emit(ConversationsLoadedState(conversations: conversations));
    }
  }

  void saveNewMessage(Message newMessage) async {
    var box = await Hive.openBox<Conversation>('conversation');
    var mbox = await Hive.openBox<SavedMessage>('savedmessage');

    mbox.add(
        SavedMessage(newMessage.conversationId, Message.toJson(newMessage)));

    List<Conversation> conversations = box.values.toList();

    int index = conversations.indexWhere(
        (element) => element.conversationID == newMessage.conversationId);

    Conversation c = conversations[index];

    c.latestMessage = newMessage;
    c.latestMessageJSON = Message.toJson(newMessage);

    conversations[index] = c;

    box.putAt(index, c);

    if (state is ConversationsLoadedState) {
      conversations.sort((a, b) => b.latestMessage!.messageDateTime!
          .compareTo(a.latestMessage!.messageDateTime!));

      emit(ConversationsUpdatingState());
      emit(ConversationsLoadedState(conversations: conversations));
    }
  }

  void updateConversatinOnSend(Message newMessage) async {
    if (chatCubit.newConvoId != null) {
      newMessage.conversationId = chatCubit.newConvoId;
    }

    if (state is ChatLoadedState) {
      List<Conversation> conversations =
          (state as ConversationsLoadedState).conversations!;

      int index = conversations.indexWhere(
          (element) => element.conversationID == newMessage.conversationId);

      Conversation c = conversations[index];

      c.latestMessage = newMessage;
      c.latestMessageJSON = Message.toJson(newMessage);

      conversations[index] = c;

      conversations.sort((a, b) => b.latestMessage!.messageDateTime!
          .compareTo(a.latestMessage!.messageDateTime!));

      emit(ConversationsUpdatingState());
      emit(ConversationsLoadedState(conversations: conversations));
    }

    try {
      var result = await chatRepository.sendMessage(newMessage);
      newMessage.messageStatus = MESSAGE_STATUS_SENT;

      if (result is bool) {
        var box = await Hive.openBox<Conversation>('conversation');
        var mbox = await Hive.openBox<SavedMessage>('savedmessage');

        mbox.add(SavedMessage(
            newMessage.conversationId, Message.toJson(newMessage)));

        List<Conversation> conversations = box.values.toList();

        int index = conversations.indexWhere(
            (element) => element.conversationID == newMessage.conversationId);

        Conversation c = conversations[index];

        c.latestMessage = newMessage;
        c.latestMessageJSON = Message.toJson(newMessage);

        conversations[index] = c;

        box.putAt(index, c);

        if (state is ConversationsLoadedState) {
          conversations.sort((a, b) => b.latestMessage!.messageDateTime!
              .compareTo(a.latestMessage!.messageDateTime!));

          emit(ConversationsUpdatingState());
          emit(ConversationsLoadedState(conversations: conversations));
        }
      } else if (result is Conversation) {
        Conversation conversation = result;

        newMessage.conversationId = conversation.conversationID;
        chatCubit.setNewConversationId(conversation.conversationID);

        var box = await Hive.openBox<Conversation>('conversation');
        var sbox = await Hive.openBox<SavedMessage>('savedmessage');

        sbox.add(SavedMessage(
            newMessage.conversationId, Message.toJson(newMessage)));

        box.add(conversation);

        if (state is ConversationsLoadedState) {
          List<Conversation> conversations =
              (state as ConversationsLoadedState).conversations!;

          conversations.insert(0, conversation);

          conversations.sort((a, b) => b.latestMessage!.messageDateTime!
              .compareTo(a.latestMessage!.messageDateTime!));

          emit(ConversationsLoadedState(conversations: conversations));
        }
      }
    } on ChatException catch (_) {
      newMessage.messageStatus = MESSAGE_STATUS_ERROR;
      chatCubit.updateMessage(newMessage);
    }
  }

  void updateMessage(BuildContext context, Message message) async {
    var box = await Hive.openBox<SavedMessage>('savedmessage');
    int index = box.values.toList().indexWhere((element) {
      if (element.conversationId != message.conversationId) return false;
      Message m = Message.fromJson(element.messageJSON);

      if (m.messageDateTime == message.messageDateTime) return true;

      return false;
    });

    box.putAt(
        index, SavedMessage(message.conversationId, Message.toJson(message)));

    final ChatCubit chatCubit = BlocProvider.of<ChatCubit>(context);
    chatCubit.updateMessage(message);
  }

  void updateConversation(var data, [bool showNotification = true]) async {
    Message newMessage;

    switch (data["messageType"]) {
      case MESSAGE_TYPE_MEDIA:
        newMessage = MediaMessage.fromJson(jsonDecode(data["message"]));
        break;
      case MESSAGE_TYPE_POST:
        newMessage = SocialPostMessage.fromJson(jsonDecode(data["message"]));
        break;
      default:
        newMessage = TextMessage.fromJson(jsonDecode(data["message"]));
        break;
    }

    if (data["command"] == "add_message_conversation") {
      Conversation conversation =
          Conversation.fromJson(jsonDecode(data['conversation']));

      print("Convo");
      print(conversation.toJson());

      conversation.conversationPerson = newMessage.sender;
      newMessage.conversationId = conversation.conversationID;

      var box = await Hive.openBox<Conversation>('conversation');
      var sbox = await Hive.openBox<SavedMessage>('savedmessage');

      sbox.add(
          SavedMessage(newMessage.conversationId, Message.toJson(newMessage)));
      box.add(conversation);

      if (state is ConversationsLoadedState) {
        List<Conversation> conversations =
            (state as ConversationsLoadedState).conversations!;

        conversations.insert(0, conversation);
        conversations.sort((a, b) => b.latestMessage!.messageDateTime!
            .compareTo(a.latestMessage!.messageDateTime!));

        emit(ConversationsLoadedState(conversations: conversations));
      }
    } else {
      String conversationId = newMessage.conversationId!;

      var box = await Hive.openBox<Conversation>('conversation');
      var m = await Hive.openBox<SavedMessage>('savedmessage');

      m.add(SavedMessage(conversationId, jsonDecode(data["message"])));

      List<Conversation> conversations = box.values.toList();

      int index = conversations
          .indexWhere((element) => element.conversationID == conversationId);

      if (index != -1) {
        Conversation c = conversations[index];

        if (newMessage.sender!.personID != sharedPrefs.userId)
          c.newMessagesCount = c.newMessagesCount! + 1;

        print(c.newMessagesCount);

        c.latestMessage = newMessage;
        c.latestMessageJSON = Message.toJson(newMessage);

        conversations[index] = c;

        box.putAt(index, c);
      }

      if (state is ConversationsLoadedState) {
        conversations.sort((a, b) => b.latestMessage!.messageDateTime!
            .compareTo(a.latestMessage!.messageDateTime!));

        if (newMessage.sender!.personID! != sharedPrefs.userId)
          chatCubit.addNewChat(newMessage);

        emit(ConversationsUpdatingState());
        emit(ConversationsLoadedState(conversations: conversations));
      }
    }

    if (showNotification) _showMessageNotification(newMessage);
  }

  void _showMessageNotification(Message newMessage) {
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

    if (chatCubit.currentConversationId == newMessage.conversationId) return;
    if (!sharedPrefs.mutedConversations.contains(newMessage.conversationId))
      AwesomeNotifications().createNotification(
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
}
