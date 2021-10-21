import 'package:hive/hive.dart';

part 'saved_message.g.dart';

@HiveType(typeId: 6)
class SavedMessage {
  @HiveField(0)
  String conversationId;

  @HiveField(1)
  Map messageJSON;

  SavedMessage(this.conversationId, this.messageJSON);
}
