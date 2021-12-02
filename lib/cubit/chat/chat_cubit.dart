import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/state/chat_state.dart';
import 'package:groovenation_flutter/data/repo/chat_repository.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.context, this.chatRepository) : super(ChatInitialState());

  final ChatRepository chatRepository;
  String? currentConversationId;
  final BuildContext context;

  void getChats(String? conversationId, int page) async {
    newConvoId = null;

    if (conversationId == null) {
      emit(ChatLoadedState(messages: [], hasReachedMax: true));
      return;
    }

    currentConversationId = conversationId;
    newConvoId = null;

    var box = await Hive.openBox<SavedMessage>('savedmessage');

    print("Box: " + box.toMap().toString());

    List<Message> allMessages = [];

    var messages = box
        .toMap()
        .values
        .where((element) => element.conversationId == conversationId);

    print("Box: " + messages.toString());

    for (var item in messages) {
      allMessages.add(Message.fromJson(item.messageJSON));
    }

    allMessages
        .sort((a, b) => b.messageDateTime!.compareTo(a.messageDateTime!));

    emit(ChatLoadedState(messages: allMessages, hasReachedMax: true));
  }

  void sendChat(Message message) async {
    final ConversationsCubit conversationsCubit =
        BlocProvider.of<ConversationsCubit>(context);

    message.conversationId = currentConversationId;
    if (state is ChatLoadedState) {
      List<Message> messages = (state as ChatLoadedState).messages!;
      messages.insert(0, message);

      conversationsCubit.sendChat(message);

      bool? hasReachedMax = (state as ChatLoadedState).hasReachedMax;

      emit(ChatLoadedState(messages: messages, hasReachedMax: hasReachedMax));
    } else if (message.conversationId == null) {
      List<Message> messages = [];
      messages.add(message);

      conversationsCubit.sendChat(message);

      bool? hasReachedMax = (state as ChatLoadedState).hasReachedMax;

      emit(ChatLoadedState(messages: messages, hasReachedMax: hasReachedMax));
    } else {
      alertUtil.sendAlert(
          BASIC_ERROR_TITLE, ERROR_SENDING_MESSAGE, Colors.red, Icons.error);
    }
  }

  void addNewChat(Message message) async {
    if (state is ChatLoadedState &&
        currentConversationId == message.conversationId) {
      List<Message> messages = (state as ChatLoadedState).messages!;
      bool? hasReachedMax = (state as ChatLoadedState).hasReachedMax;

      messages.insert(0, message);

      emit(ChatUpdatingState());
      emit(ChatLoadedState(messages: messages, hasReachedMax: hasReachedMax));
    }
  }

  String? newConvoId;
  void setNewConversationId(String? id) {
    newConvoId = id;
  }

  void updateMessage(Message message) async {
    if (state is ChatLoadedState &&
        currentConversationId == message.conversationId) {
      List<Message> messages = (state as ChatLoadedState).messages!;

      int index = messages.indexWhere(
          (element) => message.messageDateTime == message.messageDateTime);
      messages[index] = message;

      bool? hasReachedMax = (state as ChatLoadedState).hasReachedMax;

      emit(ChatUpdatingState());
      emit(ChatLoadedState(messages: messages, hasReachedMax: hasReachedMax));
    }
  }
}
