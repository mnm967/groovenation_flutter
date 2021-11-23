import 'package:equatable/equatable.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';

abstract class ChatState extends Equatable {}

class ConversationsInitialState extends ChatState {
  @override
  List<Object> get props => [];
}

class ConversationsLoadingState extends ChatState {
  @override
  List<Object> get props => [];
}

class ConversationsUpdatingState extends ChatState {
  @override
  List<Object> get props => [];
}

class ConversationsLoadedState extends ChatState {
  final List<Conversation>? conversations;

  ConversationsLoadedState({this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class ChatInitialState extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatLoadingState extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatUpdatingState extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatLoadedState extends ChatState {
  final List<Message>? messages;
  final bool? hasReachedMax;

  ChatLoadedState({this.messages, this.hasReachedMax});

  @override
  List<Object?> get props => [messages, hasReachedMax];
}

class ChatErrorState extends ChatState {
  ChatErrorState(this.error);

  final AppError error;

  @override
  List<Object> get props => [error];
}