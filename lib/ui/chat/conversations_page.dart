import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/state/chat_state.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/services/database.dart';
import 'package:groovenation_flutter/ui/chat/conversation_item.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:need_resume/need_resume.dart';
import 'package:provider/provider.dart';

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ResumableState<ConversationsPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  bool isUserMessagesLoaded = true;

  void _initScrollController() {
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
  }

  @override
  void initState() {
    super.initState();

    _initScrollController();
    AwesomeNotifications().cancelAll();
  }

  @override
  void dispose() {
    sharedPrefs.onUserMessagesValueChanged = null;
    _scrollController.dispose();
    super.dispose();
  }

  List<Conversation>? conversations = [];

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
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title(),
                          BlocBuilder<ConversationsCubit, ChatState>(
                              builder: (contexts, state) {
                            if (state is ConversationPersonsLoadingState)
                              return _circularProgress();
                            else if (state is ConversationUsersErrorState) {
                              return _circularProgress();
                            }
                            else if (state is ConversationsInitialState) {
                              return _circularProgress();
                            }
                            return StreamBuilder<List<Conversation>>(
                                stream: ChatDatabase.streamConversations(
                                    sharedPrefs.userId.toString()),
                                builder: (context, snapshot) {
                                  if (Provider.of<List<Conversation>>(context)
                                          .length ==
                                      0) return Container();
                                  if (!snapshot.hasData && !snapshot.hasError)
                                    return _circularProgress();
                                  else if (snapshot.hasError)
                                    return Container();

                                  return _conversationsList(
                                      (state as ConversationPersonsLoadedState)
                                          .persons!);
                                });
                          }),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
        _scrollToTopButton()
      ],
    );
  }

  Widget _scrollToTopButton() {
    return AnimatedOpacity(
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
            child: TextButton(
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
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(900)),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.only(left: 9),
                ),
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
          padding: EdgeInsets.only(left: 24, top: 8),
          child: Text(
            "Conversations",
            style: TextStyle(
                color: Colors.white, fontSize: 36, fontFamily: 'LatoBold'),
          ),
        ),
      ],
    );
  }

  Widget _conversationsList(List<SocialPerson> users) {
    return _convoList(Provider.of<List<Conversation>>(context), users);
  }

  Widget _convoList(
      List<Conversation> conversations, List<SocialPerson> users) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 24, bottom: 8),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return ConversationItem(
              conversation: conversations[index],
              person: users.firstWhere((element) =>
                  element.personID ==
                  conversations[index].conversationPersonId),
              onClick: () {
                Navigator.pushNamed(context, '/chat',
                    arguments: ChatPageArguments(conversations[index], null));
                setState(() {});
              });
        });
  }

  Widget _circularProgress() {
    return Padding(
      padding: EdgeInsets.only(top: 64),
      child: Center(
        child: SizedBox(
          height: 56,
          width: 56,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}
