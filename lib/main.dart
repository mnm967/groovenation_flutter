import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/auth_cubit.dart';
import 'package:groovenation_flutter/cubit/change_password_cubit.dart';
import 'package:groovenation_flutter/cubit/chat_cubit.dart';
import 'package:groovenation_flutter/cubit/club_reviews_cubit.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/cubit/profile_settings_cubit.dart';
import 'package:groovenation_flutter/cubit/social_comments_cubit.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/ticket_purchase_cubit.dart';
import 'package:groovenation_flutter/cubit/tickets_cubit.dart';
import 'package:groovenation_flutter/cubit/user_cubit.dart';
import 'package:groovenation_flutter/data/repo/auth_repository.dart';
import 'package:groovenation_flutter/data/repo/chat_repository.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/data/repo/ticket_repository.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/models/send_media_task.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'constants/strings.dart';
import 'models/social_person.dart';
import 'models/conversation.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.data}");
  if (message.data.toString() != "{}") handleMessage(message.data);
}

void handleMessage(var data) async {
  print("handling...");

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

  await HiveBoxProvider.init();

  if (data["command"] == "add_message_conversation") {
    Conversation conversation =
        Conversation.fromJson(jsonDecode(data['conversation']));

    newMessage.conversationId = conversation.conversationID;

    var box = await Hive.openBox<Conversation>('conversation');
    var sbox = await Hive.openBox<SavedMessage>('savedmessage');

    sbox.add(
        SavedMessage(newMessage.conversationId, Message.toJson(newMessage)));

    box.add(conversation);
  } else {
    String conversationId = newMessage.conversationId;

    var box = await Hive.openBox<Conversation>('conversation');
    var m = await Hive.openBox<SavedMessage>('savedmessage');

    m.add(SavedMessage(conversationId, jsonDecode(data["message"])));

    List<Conversation> conversations = box.values.toList();

    int index = conversations
        .indexWhere((element) => element.conversationID == conversationId);

    if (index != -1) {
      Conversation c = conversations[index];

      c.newMessagesCount = c.newMessagesCount + 1;

      c.latestMessage = newMessage;
      c.latestMessageJSON = Message.toJson(newMessage);

      conversations[index] = c;

      box.putAt(index, c);
    }
  }

  String text;

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

  if(!sharedPrefs.mutedConversations.contains(newMessage.conversationId)) await AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: newMessage.messageID.hashCode,
        channelKey: 'groovenation_channel',
        title: "Message from ${newMessage.sender.personUsername}",
        body: text,
        largeIcon: newMessage.sender.personProfilePicURL,
        backgroundColor: Colors.deepPurple,
        color: Colors.white,
        notificationLayout: NotificationLayout.Messaging,
        summary: "New Message"),
  );

  print("done...");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    } else {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
    }
  });

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://f834be9ae7964ee3a96fc777800c9bcf@o405222.ingest.sentry.io/5772349';
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HiveLifecycleManager(
        child: MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => NearbyClubsCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => TopClubsCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => FavouritesClubsCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => EventPageClubCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => SearchClubsCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => FavouritesEventsCubit(EventsRepository())),
        BlocProvider(
            create: (context) => ClubEventsCubit(EventsRepository())),
        BlocProvider(
            create: (context) => UpcomingEventsCubit(EventsRepository())),
        BlocProvider(
            create: (context) => SearchEventsCubit(EventsRepository())),
        BlocProvider(create: (context) => TicketsCubit(TicketsRepository())),
        BlocProvider(
            create: (context) => NearbySocialCubit(SocialRepository())),
        BlocProvider(
            create: (context) => FollowingSocialCubit(SocialRepository())),
        BlocProvider(
            create: (context) => TrendingSocialCubit(SocialRepository())),
        BlocProvider(
            create: (context) => SocialCommentsCubit(SocialRepository())),
        BlocProvider(
            create: (context) => UserSocialCubit(SocialRepository())),
        BlocProvider(
            create: (context) => SocialPostCubit(SocialRepository())),
        BlocProvider(
            create: (context) => SearchUsersCubit(SocialRepository())),
        BlocProvider(
            create: (context) => ClubMomentsCubit(SocialRepository())),
        BlocProvider(
            create: (context) => SocialCommentsLikeCubit(SocialRepository())),
        BlocProvider(
            create: (context) => ChangePasswordCubit(SocialRepository())),
        BlocProvider(
            create: (context) => ConversationsCubit(ChatRepository())),
        BlocProvider(
            create: (context) => ChatCubit(context, ChatRepository())),
        BlocProvider(
            create: (context) => ClubReviewsCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => AddClubReviewCubit(ClubsRepository())),
        BlocProvider(
            create: (context) => AuthCubit(AuthRepository())),
        BlocProvider(
            create: (context) => ProfileSocialCubit(SocialRepository())),
        BlocProvider(
            create: (context) => ProfileSettingsCubit(SocialRepository())),
        BlocProvider(
            create: (context) => TicketPurchaseCubit(TicketsRepository())),
        BlocProvider(create: (context) => UserCubit(SocialRepository())),
      ],
      child: Directionality(
          textDirection: TextDirection.ltr, child: MainAppPage()),
    ));
  }
}

class HiveLifecycleManager extends StatefulWidget {
  final Widget child;

  HiveLifecycleManager({@required this.child});

  @override
  _HiveLifecycleManagerState createState() => _HiveLifecycleManagerState();
}

class _HiveLifecycleManagerState extends State<HiveLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        HiveBoxProvider.close().then((value) => HiveBoxProvider.init());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        HiveBoxProvider.close();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class HiveBoxProvider {
  static Future<dynamic> _initFlutterFuture;

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
