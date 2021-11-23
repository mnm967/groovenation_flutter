import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';

class ChatPageArguments{
  final Conversation conversation;
  final Message? messageToSend;

  ChatPageArguments(this.conversation, this.messageToSend);
}