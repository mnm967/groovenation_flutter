import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/models/send_media_task.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxProvider {
  static Future<dynamic>? _initFlutterFuture;

  static Future init() async {
    if (_initFlutterFuture == null) {
      _initFlutterFuture = Hive.initFlutter();
      registerAdapters();
    }
    await _initFlutterFuture;
  }

  static Future close() async {
    _initFlutterFuture = null;
    await Hive.close();
  }

  Future<Box<TValue>> openBox<TValue>(String name) async {
    await init();
    return await Hive.openBox<TValue>(name);
  }

  Future deleteBox(String name) async {
    return await Hive.deleteBoxFromDisk(name);
  }

  static void registerAdapters() {
    _registerAdapter(SocialPersonAdapter());
    _registerAdapter(SendMediaTaskAdapter());
    _registerAdapter(MessageAdapter());
    _registerAdapter(SavedMessageAdapter());
    _registerAdapter(TextMessageAdapter());
    _registerAdapter(MediaMessageAdapter());
    _registerAdapter(SocialPostMessageAdapter());
    _registerAdapter(ConversationAdapter());
    _registerAdapter(TicketAdapter());
  }

  static void _registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter<T>(adapter);
    }
  }
}
