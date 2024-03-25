import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide MessageHandler;
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:groovenation_flutter/groovenation_app.dart';
import 'package:groovenation_flutter/util/hive_box_provider.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/message_handler.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.toString() != "{}") {
    MessageHandler.handleMessage(message.data);
  }
}

void backgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterUploader uploader = FlutterUploader();
  uploader.progress.listen((progress) {
    // upload progress
  });
  uploader.result.listen((result) {
    // upload results
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  _initialize();
}

Future _initialize() async {
  await sharedPrefs.init();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  await locationUtil.init();

  await HiveBoxProvider.init();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'groovenation_channel',
        channelName: 'GrooveNation Notifications',
        channelDescription: 'Notification channel for GrooveNation',
        groupKey: 'grouped',
        groupSort: GroupSort.Desc,
        groupAlertBehavior: GroupAlertBehavior.Children,
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.deepPurple,
        importance: NotificationImportance.High)
  ]);

  await Firebase.initializeApp();

  // FirebaseFirestore.instance.useFirestoreEmulator('10.76.73.111', 8081);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://f834be9ae7964ee3a96fc777800c9bcf@o405222.ingest.sentry.io/5772349';
    },
    appRunner: () => runApp(GroovenationApp()),
  );

  FlutterUploader().setBackgroundHandler(backgroundHandler);
}
