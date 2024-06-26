import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/models/send_media_task.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/services/database.dart';
import 'package:groovenation_flutter/ui/chat/message_item.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final Message? messageToSendArg;

  ChatPage(this.conversation, this.messageToSendArg);

  @override
  _ChatPageState createState() => _ChatPageState(
      conversation: conversation, messageToSendArg: messageToSendArg);
}

class _ChatPageState extends State<ChatPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textEditingController = TextEditingController();

  List<Message>? messages = [];
  final Conversation? conversation;
  Message? messageToSendArg;
  int messagesPage = 0;
  bool isConversationMuted = false;

  _ChatPageState({this.conversation, this.messageToSendArg});

  @override
  void initState() {
    super.initState();

    _initScrollListener();
    _initChat();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _sendInitialMessage();
    });
  }

  void _initScrollListener() {
    return _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 30) {
        if (_scrollToTopVisible != false) {
          setState(() {
            _scrollToTopVisible = false;
          });
        }
      } else {
        if (_scrollToTopVisible != true) {
          setState(() {
            _scrollToTopVisible = true;
          });
        }
      }
    });
  }

  void _initChat() {
    if (conversation!.conversationID != null)
      isConversationMuted =
          sharedPrefs.mutedConversations.contains(conversation!.conversationID);

    checkMediaSending();
  }

  void checkMediaSending() async {
    var box = await Hive.openBox<SendMediaTask>('sendmediatask');

    SendMediaTask? task = box.values.firstWhereOrNull(
        (element) => element.receiverId == conversation!.conversationPersonId);

    if (task != null) {
      setState(() {
        isSendingMedia = true;
        _image = File(task.filePath!);
      });
    }
  }

  void _sendInitialMessage() {
    if (messageToSendArg != null) {
      switch (messageToSendArg!.messageType) {
        case MESSAGE_TYPE_POST:
          _sendSocialPostMessage(messageToSendArg as SocialPostMessage);
          Future.delayed(
              Duration(milliseconds: 1000),
              () => Navigator.popAndPushNamed(context, '/chat',
                  arguments: ChatPageArguments(conversation!, null)));
          break;
        default:
          setState(() {
            _textEditingController.text =
                (messageToSendArg as TextMessage).text!;
          });
          _sendTextMessage();
          break;
      }
    }
  }

  void _sendSocialPostMessage(SocialPostMessage message) {
    ChatDatabase.sendMessage(
        conversation!.conversationID!,
        sharedPrefs.userId!,
        conversation!.conversationPersonId!,
        jsonEncode(SocialPostMessage.getJson(message)),
        DateTime.now().microsecondsSinceEpoch.toString());
  }

  void _sendTextMessage() {
    TextMessage t = TextMessage(
        null,
        conversation!.conversationID != null
            ? conversation!.conversationID
            : null,
        DateTime.now(),
        SocialPerson(
            sharedPrefs.userId,
            sharedPrefs.username,
            sharedPrefs.profilePicUrl,
            sharedPrefs.coverPicUrl,
            false,
            false,
            sharedPrefs.userFollowersCount),
        _textEditingController.text,
        conversation!.conversationPersonId);

    ChatDatabase.sendMessage(
        conversation!.conversationID!,
        sharedPrefs.userId!,
        conversation!.conversationPersonId!,
        jsonEncode(TextMessage.getJson(t)),
        DateTime.now().microsecondsSinceEpoch.toString());

    setState(() {
      _textEditingController.text = "";
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  late File _image;
  final picker = ImagePicker();
  final uploader = FlutterUploader();
  bool isSendingMedia = false;

  Future _getMediaImageFile() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);

      final taskId = await uploader.enqueue(
        MultipartFormDataUpload(
            url: "$API_HOST/chat/send/media",
            files: [FileItem(path: pickedFile.path, field: 'image_file')],
            method: UploadMethod.POST,
            headers: {"authorization": "Bearer ${sharedPrefs.authToken}"},
            data: {
              "conversationId": conversation!.conversationID!,
              "userId": sharedPrefs.userId!,
              "receiverId": conversation!.conversationPersonId!,
            },
            tag: conversation!.conversationPersonId),
      );

      setState(() {
        isSendingMedia = true;
      });

      var box = await Hive.openBox<SendMediaTask>('sendmediatask');

      SendMediaTask task = SendMediaTask(
          taskId, _image.path, conversation!.conversationPersonId);
      box.put(conversation!.conversationPersonId, task);

      executeUpload(taskId);
    }
  }

  void executeUpload(String taskId) {
    uploader.result.listen((result) async {
      if (result.taskId == taskId) {
        if (result.response == null) return;

        Map<String, dynamic> jsonResponse = jsonDecode(result.response!);

        if (jsonResponse['status'] == 1) {
          Message nMessage =
              Message.fromJson(jsonDecode(jsonResponse['message']));
          nMessage.messageStatus = MESSAGE_STATUS_SENT;

          var sbox = await Hive.openBox<SendMediaTask>('sendmediatask');
          sbox.delete(nMessage.receiverId);

          ChatDatabase.sendMessage(
              conversation!.conversationID!,
              sharedPrefs.userId!,
              conversation!.conversationPersonId!,
              jsonEncode(MediaMessage.getJson(nMessage as MediaMessage)),
              DateTime.now().microsecondsSinceEpoch.toString());

          try {
            if (mounted)
              setState(() {
                isSendingMedia = false;
              });

            return;
          } catch (e) {
            print(e);
          }

          _updateConversationCubit(jsonResponse, nMessage);
        } else {
          var sbox = await Hive.openBox<SendMediaTask>('sendmediatask');
          sbox.delete(conversation!.conversationPersonId);

          try {
            if (mounted)
              setState(() {
                isSendingMedia = false;
              });
          } catch (e) {}
        }
      }
    }, onError: (ex, stacktrace) async {
      var sbox = await Hive.openBox<SendMediaTask>('sendmediatask');
      sbox.delete(conversation!.conversationPersonId);

      try {
        if (mounted)
          setState(() {
            isSendingMedia = false;
          });
      } catch (e) {}
    });
  }

  void _updateConversationCubit(var jsonResponse, Message nMessage) async {
    var box = await Hive.openBox<Conversation>('conversation');
    var m = await Hive.openBox<SavedMessage>('savedmessage');

    m.add(SavedMessage(
        nMessage.conversationId, jsonDecode(jsonResponse['message'])));

    List<Conversation> conversations = box.values.toList();

    int index = conversations.indexWhere(
        (element) => element.conversationID == nMessage.conversationId);

    if (index != -1) {
      Conversation c = conversations[index];

      c.latestMessage = nMessage;
      c.latestMessageJSON = Message.toJson(nMessage);

      conversations[index] = c;

      box.putAt(index, c);
    }
  }

  void executeBlock(bool block) async {
    setState(() {
      conversation!.person!.hasUserBlocked = block;
    });

    final UserSocialCubit userSocialCubit =
        BlocProvider.of<UserSocialCubit>(context);

    bool userBlockSuccess = await userSocialCubit.blockUser(
        context, conversation!.person!, conversation!.person!.hasUserBlocked!);

    if (!userBlockSuccess)
      setState(() {
        conversation!.person!.hasUserBlocked =
            !conversation!.person!.hasUserBlocked!;
      });
  }

  _onPopupMenuItemSelected(item) {
    switch (item) {
      case 'View User':
        Navigator.pushNamed(context, '/profile_page',
            arguments: conversation!.person);
        break;
      case 'Unmute notifications':
        if (conversation!.conversationID == null) break;

        List<String> mutedConversations = sharedPrefs.mutedConversations;
        mutedConversations.remove(conversation!.conversationID);
        sharedPrefs.mutedConversations = mutedConversations;

        setState(() {
          isConversationMuted = false;
        });

        break;

      case 'Mute notifications':
        if (conversation!.conversationID == null) break;

        List<String> mutedConversations = sharedPrefs.mutedConversations;
        mutedConversations.add(conversation!.conversationID!);
        sharedPrefs.mutedConversations = mutedConversations;

        setState(() {
          isConversationMuted = true;
        });

        break;
      case 'Block User':
        executeBlock(true);
        break;
      case 'Unblock User':
        executeBlock(false);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _mainBody());
  }

  void _changeConversationMuted() {
    if (isConversationMuted) {
      if (conversation!.conversationID == null) return;

      List<String> mutedConversations = sharedPrefs.mutedConversations;
      mutedConversations.remove(conversation!.conversationID);
      sharedPrefs.mutedConversations = mutedConversations;

      setState(() {
        isConversationMuted = false;
      });
    } else {
      if (conversation!.conversationID == null) return;

      List<String> mutedConversations = sharedPrefs.mutedConversations;
      mutedConversations.add(conversation!.conversationID!);
      sharedPrefs.mutedConversations = mutedConversations;

      setState(() {
        isConversationMuted = true;
      });
    }
  }

  Widget _appBar() {
    return PreferredSize(
      child: AppBar(
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(left: 0),
              child: SizedBox(
                height: 48,
                width: 48,
                child: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.5),
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile_page',
                            arguments: conversation!.person);
                      },
                      child: Container()),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  conversation!.conversationPersonId!,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'LatoBold',
                      fontSize: 17,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
              onSelected: _onPopupMenuItemSelected,
              itemBuilder: (BuildContext context) {
                return [
                  'View User',
                ].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(
                      choice,
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  );
                }).toList();
              }),
        ],
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
      ),
      preferredSize: Size.fromHeight(72),
    );
  }

  Widget _mainBody() {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: _messagesList()),
              isSendingMedia
                  ? Padding(
                      padding: EdgeInsets.only(top: 0, left: 12, right: 12),
                      child: Card(
                        elevation: 0,
                        color: Colors.deepPurple,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Container(
                          padding: EdgeInsets.zero,
                          child: Wrap(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [_sendingMediaText()],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
              _chatTextbox()
            ],
          ),
        ),
        _scrollTopButton()
      ],
    );
  }

  List<DocumentSnapshot> listMessage = [];
  final ScrollController listScrollController = ScrollController();

  Widget _messagesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .doc(conversation!.conversationID!)
          .collection(conversation!.conversationID!)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          listMessage = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (BuildContext context, int index) => MessageItem(
              isRight: Message.fromFireStore(snapshot.data!.docs[index])
                      .sender!
                      .personID ==
                  sharedPrefs.userId,
              message: Message.fromFireStore(snapshot.data!.docs[index]),
            ),
            itemCount: snapshot.data!.docs.length,
            reverse: true,
            controller: listScrollController,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _sendingMediaText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(height: 48, width: 48, child: Image.file(_image))),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, right: 3),
                        child: Text(
                          "Sending Media...",
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.5)),
              strokeWidth: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chatTextbox() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 196),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.deepPurple, borderRadius: BorderRadius.circular(9)),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: (text) {
              setState(() {});
            },
            controller: _textEditingController,
            cursorColor: Colors.white.withOpacity(0.7),
            style: TextStyle(
                fontFamily: 'Lato',
                color: Colors.white.withOpacity(0.7),
                fontSize: 18),
            decoration: InputDecoration(
              hintMaxLines: 3,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              hintText: "Type your Message",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              suffixIcon: _textEditingController.text.isEmpty
                  ? (!isSendingMedia
                      ? IconButton(
                          icon: Icon(Icons.image),
                          color: Colors.white.withOpacity(0.5),
                          padding: EdgeInsets.only(right: 20),
                          iconSize: 28,
                          onPressed: () {
                            _getMediaImageFile();
                          })
                      : null)
                  : IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.white.withOpacity(0.5),
                      padding: EdgeInsets.only(right: 20),
                      iconSize: 28,
                      onPressed: () {
                        _sendTextMessage();
                      }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scrollTopButton() {
    return AnimatedOpacity(
      opacity: _scrollToTopVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(bottom: 96, right: 16),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: TextButton(
              onPressed: () {
                _scrollController.animateTo(
                  0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
              },
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(1),
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
