import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/chat_cubit.dart';
import 'package:groovenation_flutter/cubit/state/chat_state.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:need_resume/need_resume.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ResumableState<ConversationsPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  bool isUserMessagesLoaded = true;

  @override
  void initState() {
    super.initState();

    AwesomeNotifications().cancelAll();

    isUserMessagesLoaded = sharedPrefs.isUserMessagesLoaded;
    if (!isUserMessagesLoaded)
      sharedPrefs.onUserMessagesValueChanged = () {
        setState(() {
          isUserMessagesLoaded = sharedPrefs.isUserMessagesLoaded;
        });
      };

    _scrollController.addListener(() {
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

    final ConversationsCubit conversationsCubit =
        BlocProvider.of<ConversationsCubit>(context);
    // if (!conversationsCubit.isChatLoadedState())
    conversationsCubit.getConversations();
  }

  @override
  void onResume() {
    final ConversationsCubit conversationsCubit =
        BlocProvider.of<ConversationsCubit>(context);

    conversationsCubit.getConversations();
    super.onResume();
  }

  @override
  void dispose() {
    sharedPrefs.onUserMessagesValueChanged = null;
    _scrollController.dispose();
    super.dispose();
  }

  List<Conversation> conversations = [];

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                  child: SafeArea(
                      child: Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(left: 8, top: 8),
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(900)),
                                        child: FlatButton(
                                          padding: EdgeInsets.only(left: 9),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      )),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 24, top: 8),
                                      child: Text(
                                        "Conversations",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontFamily: 'LatoBold'),
                                      )),
                                ],
                              ),
                              BlocBuilder<ConversationsCubit, ChatState>(
                                  builder: (context, chatState) {
                                if (!isUserMessagesLoaded) {
                                  return Padding(
                                      padding: EdgeInsets.only(top: 96),
                                      child: Column(
                                        children: [
                                          Center(
                                              child: SizedBox(
                                            height: 56,
                                            width: 56,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                              strokeWidth: 2.0,
                                            ),
                                          )),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 36, left: 16, right: 16),
                                            child: Center(
                                              child: Text(
                                                "Loading Messages. Sit tight, this only needs to be done once...",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontFamily: 'Lato',
                                                    fontSize: 20),
                                              ),
                                            ),
                                          )
                                        ],
                                      ));
                                }

                                if (chatState is ConversationsLoadedState) {
                                  conversations = chatState.conversations;
                                }

                                if (chatState is ConversationsLoadingState &&
                                    conversations.isEmpty) {
                                  return Padding(
                                      padding: EdgeInsets.only(top: 64),
                                      child: Center(
                                          child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2.0,
                                        ),
                                      )));
                                }

                                return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding:
                                        EdgeInsets.only(top: 24, bottom: 8),
                                    itemCount: conversations.length,
                                    itemBuilder: (context, index) {
                                      return conversationItem(
                                          context, conversations[index]);
                                    });
                              }),
                            ],
                          ))))
            ],
          ),
        ),
        AnimatedOpacity(
            opacity: _scrollToTopVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 250),
            child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16, right: 16),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(9)),
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _scrollController.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white.withOpacity(0.7),
                        size: 36,
                      ),
                    ),
                  ),
                )))
      ],
    );
  }

  Widget conversationItem(BuildContext context, Conversation conversation) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          elevation: 4,
          color: Colors.deepPurple,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: FlatButton(
              onPressed: () {
                pushNamed(context, '/chat',
                    arguments: ChatPageArguments(conversation, null));
                setState(() {});
              },
              padding: EdgeInsets.zero,
              child: Wrap(children: [
                Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                    padding: EdgeInsets.zero,
                                    child: SizedBox(
                                        height: 64,
                                        width: 64,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Colors.purple.withOpacity(0.5),
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  conversation
                                                      .conversationPerson
                                                      .personProfilePicURL),
                                          // child: FlatButton(
                                          //     onPressed: () {
                                          //       print("object");
                                          //     },
                                          //     child: Container()),
                                        ))),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4, right: 3),
                                                    child: Text(
                                                      conversation
                                                          .conversationPerson
                                                          .personUsername,
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'LatoBold',
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${timeago.format(conversation.latestMessage.messageDateTime)}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontFamily: 'LatoLight',
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 3),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Visibility(
                                                        visible: conversation
                                                                .latestMessage
                                                                .sender
                                                                .personID ==
                                                            sharedPrefs.userId,
                                                        child: Icon(Icons.check,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.4))),
                                                    Expanded(
                                                        child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 4,
                                                                    right: 1),
                                                            child: Text(
                                                              (conversation.latestMessage
                                                                      is TextMessage)
                                                                  ? (conversation.latestMessage
                                                                          as TextMessage)
                                                                      .text
                                                                  : ((conversation
                                                                              .latestMessage
                                                                          is MediaMessage)
                                                                      ? (conversation.latestMessage.receiverId ==
                                                                              sharedPrefs
                                                                                  .userId
                                                                          ? "Sent you an Image"
                                                                          : "Sent an Image")
                                                                      : (conversation.latestMessage.receiverId ==
                                                                              sharedPrefs.userId
                                                                          ? "Sent you a Post"
                                                                          : "Sent a Post")),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Lato',
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.4)),
                                                            ))),
                                                    Visibility(
                                                        visible: conversation
                                                                .newMessagesCount >
                                                            0,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 2,
                                                                  left: 3),
                                                          child: SizedBox(
                                                            height: 24,
                                                            width: 24,
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Container(
                                                                child: Center(
                                                                  child: Text(
                                                                    conversation
                                                                        .newMessagesCount
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Lato',
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                  ],
                                                )),
                                          ],
                                        )))
                              ],
                            )
                          ],
                        )),
                  ],
                )
              ])),
        ));
  }
}
