import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/state/chat_state.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/ui/chat/conversation_item.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:need_resume/need_resume.dart';

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

  void initConversationsCubit() {
    isUserMessagesLoaded = sharedPrefs.isUserMessagesLoaded;
    if (!isUserMessagesLoaded)
      sharedPrefs.onUserMessagesValueChanged = () {
        setState(() {
          isUserMessagesLoaded = sharedPrefs.isUserMessagesLoaded;
        });
      };

    final ConversationsCubit conversationsCubit =
        BlocProvider.of<ConversationsCubit>(context);

    conversationsCubit.getConversations();
  }

  @override
  void initState() {
    super.initState();

    _initScrollController();
    AwesomeNotifications().cancelAll();
    initConversationsCubit();
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
                        _conversationsList(),
                      ],
                    ),
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

  Widget _conversationsList() {
    return BlocBuilder<ConversationsCubit, ChatState>(
        builder: (context, chatState) {
      if (!isUserMessagesLoaded) {
        return _loadingView();
      }

      if (chatState is ConversationsLoadedState) {
        conversations = chatState.conversations;
      }

      if (chatState is ConversationsLoadingState && conversations!.isEmpty)
        _circularProgress();

      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 24, bottom: 8),
          itemCount: conversations!.length,
          itemBuilder: (context, index) {
            return ConversationItem(
                conversation: conversations![index],
                onClick: () {
                  Navigator.pushNamed(context, '/chat',
                      arguments: ChatPageArguments(conversations![index], null));
                  setState(() {});
                });
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

  Widget _loadingView() {
    return Padding(
      padding: EdgeInsets.only(top: 96),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 36, left: 16, right: 16),
            child: Center(
              child: Text(
                "Loading Messages. Sit tight, this only needs to be done once...",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Lato',
                    fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
