import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/cubit/user/user_cubit.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/ui/search/widgets/profile_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowingPage extends StatefulWidget {
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  bool _scrollToTopVisible = false;
  ScrollController _scrollController = new ScrollController();
  final _followingRefreshController = RefreshController(initialRefresh: false);

  List<SocialPerson>? _socialPeople = [];
  bool? _hasReachedMax = false;
  String _currentSearchTerm = "";
  int _page = 0;

  ClassicFooter _classicFooter = ClassicFooter(
    textStyle: TextStyle(
        color: Colors.white.withOpacity(0.5), fontSize: 16, fontFamily: 'Lato'),
    noDataText: "You've reached the end of the line",
    failedText: "Something Went Wrong",
  );

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
    BlocUtil.clearSearchCubits(context);
    _initScrollController();

    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    userCubit.getFollowing(_page);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
              children: [
                _header(),
                Padding(padding: EdgeInsets.only(top: 16)),
                topAppBar(),
                Expanded(
                  child: _followingListBloc(),
                ),
              ],
            ),
          ),
          _scrollToTopButton(),
        ],
      ),
    );
  }

  void _onSearchInputChanged(value) {
    _currentSearchTerm = value;
    _page = 0;
    if (value.isEmpty) {
      final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
      if (!(userCubit.state is UserFollowingLoadingState))
        userCubit.getFollowing(_page);
    } else {
      final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
      userCubit.searchFollowing(_page, value);
    }
  }

  Widget topAppBar() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.2)),
            child: TextField(
              keyboardType: TextInputType.text,
              autofocus: false,
              onChanged: _onSearchInputChanged,
              cursorColor: Colors.white.withOpacity(0.7),
              style: TextStyle(
                  fontFamily: 'Lato', color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                hintMaxLines: 3,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.2),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onRefresh() {
    _page = 0;
    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    if (!(userCubit.state is UserFollowingLoadingState)) {
      if (_currentSearchTerm.isEmpty)
        userCubit.getFollowing(0);
      else
        userCubit.searchFollowing(0, _currentSearchTerm);
    }
  }

  void _onLoading() {
    if (_socialPeople!.length == 0 || _hasReachedMax!) return;

    _page++;
    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    if (!(userCubit.state is UserFollowingLoadingState)) {
      if (_currentSearchTerm.isEmpty)
        userCubit.getFollowing(_page);
      else
        userCubit.searchFollowing(_page, _currentSearchTerm);
    }
  }

  void _blocListener(context, state) {
    if (state is UserFollowingErrorState) {
      switch (state.error) {
        case AppError.NETWORK_ERROR:
          alertUtil.sendAlert(
              BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
          break;
        default:
          alertUtil.sendAlert(
              BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
          break;
      }
    }
  }

  Widget _followingListBloc() {
    return BlocConsumer<UserCubit, UserState>(
      listener: _blocListener,
      builder: (context, state) {
        if (state is UserFollowingLoadingState) {
          return _circularProgress();
        }

        if (state is UserFollowingLoadedState) {
          if (_page == 0)
            _socialPeople = state.socialPeople;
          else
            _socialPeople!.addAll(state.socialPeople!);

          _hasReachedMax = state.hasReachedMax;
        }

        return SmartRefresher(
          controller: _followingRefreshController,
          header: CustomMaterialClassicHeader(),
          footer: _classicFooter,
          onLoading: _onLoading,
          onRefresh: _onRefresh,
          enablePullDown: false,
          enablePullUp: true,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            shrinkWrap: true,
            itemCount: _socialPeople!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Align(
                  child: ProfileItem(
                    person: _socialPeople![index],
                    onUserSelected: (person) {
                      Navigator.pushNamed(context, '/profile_page',
                          arguments: person);
                    },
                  ),
                  alignment: Alignment.topCenter,
                ),
              );
            },
          ),
        );
      },
    );
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

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(900)),
            child: FlatButton(
              padding: EdgeInsets.only(left: 8),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 36, top: 12),
          child: Text(
            "Following",
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontFamily: 'LatoBold'),
          ),
        ),
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
          padding: EdgeInsets.only(bottom: 24, right: 24),
          child: Card(
            elevation: 6,
            color: Colors.deepPurple,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  color: Colors.deepPurple,
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
                  color: Colors.white.withOpacity(0.8),
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
