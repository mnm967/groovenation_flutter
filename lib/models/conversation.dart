import 'package:groovenation_flutter/models/social_person.dart';

class Conversation {
  final String conversationID;
  final SocialPerson conversationPerson;
  final bool isMuted;

  Conversation(
    this.conversationID, 
    this.conversationPerson, 
    this.isMuted
  );
}