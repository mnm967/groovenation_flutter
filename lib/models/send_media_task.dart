import 'package:hive/hive.dart';

part 'send_media_task.g.dart';

@HiveType(typeId: 7)
class SendMediaTask {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  String filePath;
  
  @HiveField(2)
  String receiverId;

  SendMediaTask(this.taskId, this.filePath, this.receiverId);
}