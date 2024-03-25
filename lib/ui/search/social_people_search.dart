import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/search/search_users_cubit.dart';
import 'package:groovenation_flutter/cubit/state/user_cubit_state.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/ui/search/widgets/profile_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SocialPeopleSearchPage extends StatefulWidget {
  final Function? onUserSelected;

  const SocialPeopleSearchPage({Key? key, this.onUserSelected})
      : super(key: key);

  @override
  _SocialPeopleSearchPageState createState() => _SocialPeopleSearchPageState();
}

class _SocialPeopleSearchPageState extends State<SocialPeopleSearchPage>
    with SingleTickerProviderStateMixin {
  Function? onUserSelected;

  bool _scrollToTopVisible = false;

  final searchTextController = TextEditingController();
  TabController? _tabController;

  ScrollController _profileScrollController = new ScrollController();
  RefreshController _profileRefreshController =
      RefreshController(initialRefresh: false);

  void _initScrollController() {
    _profileScrollController.addListener(() {
      if (_profileScrollController.position.pixels <= 30) {
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
    onUserSelected = widget.onUserSelected;
    _tabController = TabController(vsync: this, length: 1);
    _initScrollController();
  }

  @override
  void dispose() {
    _profileScrollController.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  Widget _topAppBar() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white.withOpacity(0.2)),
            child: _searchInput(),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(FontAwesomeIcons.users),
              text: "People",
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _searchInputDecoration(context) => InputDecoration(
        hintMaxLines: 3,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintText: "Search...",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(
            Icons.search,
            color: Colors.white,
            size: 28,
          ),
        ),
        prefixIcon: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.only(left: 16, right: 24),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  void _onSearchInputChanged(text) {
    if (text.isNotEmpty) {
      final SearchUsersCubit searchUsersCubit =
          BlocProvider.of<SearchUsersCubit>(context);

      profilePage = 0;
      searchUsers = [];

      searchUsersCubit.searchUsers(0, searchTextController.text);
    }
  }

  Widget _searchInput() {
    return TextField(
      controller: searchTextController,
      textInputAction: TextInputAction.go,
      keyboardType: TextInputType.multiline,
      autofocus: true,
      cursorColor: Colors.white.withOpacity(0.7),
      onChanged: (text) => _onSearchInputChanged(text),
      style: TextStyle(fontFamily: 'Lato', color: Colors.white, fontSize: 20),
      decoration: _searchInputDecoration(context),
    );
  }

  int profilePage = 0;
  List<SocialPerson>? searchUsers = [];

  void _loadProfileList() {
    if (searchUsers!.length == 0) {
      _profileRefreshController.loadComplete();
      return;
    }

    final SearchUsersCubit searchUsersCubit =
        BlocProvider.of<SearchUsersCubit>(context);

    searchUsersCubit.searchUsers(profilePage + 1, searchTextController.text);
    profilePage++;
  }

  void _refreshProfileList() {
    final SearchUsersCubit searchUsersCubit =
        BlocProvider.of<SearchUsersCubit>(context);
    profilePage = 0;
    searchUsers = [];

    searchUsersCubit.searchUsers(0, searchTextController.text);
  }

  void _profileListBlocListener(context, state) {
    if (state is SocialUsersSearchLoadedState) {
      if (_profileRefreshController.isRefresh) {
        _profileScrollController.jumpTo(0.0);
        _profileRefreshController.refreshCompleted();
        _profileRefreshController.loadComplete();

        _profileRefreshController = RefreshController(initialRefresh: false);
      } else if (_profileRefreshController.isLoading) {
        if (state.hasReachedMax!)
          _profileRefreshController.loadNoData();
        else
          _profileRefreshController.loadComplete();
      }
    }
  }

  Widget _profileListViewBuilder() {
    return ListView.builder(
      controller: _profileScrollController,
      padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: searchUsers!.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: ProfileItem(
              person: searchUsers![index],
              onUserSelected: (person) {
                onUserSelected!(person);
                Navigator.pop(context);
              }),
        );
      },
    );
  }

  Widget _profileList() {
    return BlocConsumer<SearchUsersCubit, UserState>(
      listener: _profileListBlocListener,
      builder: (context, searchUsersState) {
        if (searchUsersState is SocialUsersSearchLoadedState)
          searchUsers = searchUsersState.socialPeople;

        if (searchUsersState is SocialUsersSearchErrorState &&
            searchUsersState.error != AppError.REQUEST_CANCELLED)
          return Container(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Text(
              "Something Went Wrong. Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontFamily: 'Lato'),
            ),
          );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (searchUsersState is SocialUsersSearchLoadingState &&
                    profilePage == 0)
                ? _circularProgress()
                : Container(),
            Expanded(
              child: SmartRefresher(
                controller: _profileRefreshController,
                header: CustomMaterialClassicHeader(),
                footer: ClassicFooter(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato'),
                  noDataText: "You've reached the end of the line",
                  failedText: "Something Went Wrong",
                ),
                onRefresh: _refreshProfileList,
                onLoading: _loadProfileList,
                enablePullUp: true,
                child: _profileListViewBuilder(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _circularProgress() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
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

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: DefaultTabController(
        length: 1,
        child: Stack(
          children: [
            Column(
              children: [
                _topAppBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_profileList()],
                  ),
                )
              ],
            ),
            _scrollToTopButton(),
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    _profileScrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
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
              onPressed: _scrollToTop,
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
}
