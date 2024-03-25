import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/state/clubs_state.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/ui/clubs/widgets/club_item.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClubSearchPage extends StatefulWidget {
  final Function? onClubSelected;

  const ClubSearchPage({Key? key, this.onClubSelected}) : super(key: key);

  @override
  _ClubSearchPageState createState() => _ClubSearchPageState();
}

class _ClubSearchPageState extends State<ClubSearchPage>
    with SingleTickerProviderStateMixin {
  Function? onClubSelected;

  bool _scrollToTopVisible = false;
  final searchTextController = TextEditingController();
  late FavouritesClubsCubit _favouritesClubsCubit;

  ScrollController _scrollController = new ScrollController();
  RefreshController _clubsRefreshController =
      RefreshController(initialRefresh: false);

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
    onClubSelected = widget.onClubSelected;
    _initScrollController();
    _favouritesClubsCubit = BlocProvider.of<FavouritesClubsCubit>(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                topAppBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _clubList(),
                    ],
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

  //App Bar/Search Input:

  Widget topAppBar() {
    return Column(
      children: [
        _searchTextField(),
        TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.local_bar),
              text: "Clubs",
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _searchInputDecoration() {
    return InputDecoration(
      hintMaxLines: 3,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
  }

  void _onSearchInputChanged(text) {
    if (text.isNotEmpty) {
      final SearchClubsCubit searchClubsCubit =
          BlocProvider.of<SearchClubsCubit>(context);

      clubsPage = 0;
      searchClubs = [];

      searchClubsCubit.searchClubs(0, searchTextController.text);
    }
  }

  Widget _searchTextField() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white.withOpacity(0.2)),
        child: TextField(
          controller: searchTextController,
          textInputAction: TextInputAction.go,
          keyboardType: TextInputType.multiline,
          autofocus: true,
          cursorColor: Colors.white.withOpacity(0.7),
          onChanged: _onSearchInputChanged,
          style:
              TextStyle(fontFamily: 'Lato', color: Colors.white, fontSize: 20),
          decoration: _searchInputDecoration(),
        ),
      ),
    );
  }

  //List:

  int clubsPage = 0;
  List<Club?>? searchClubs = [];

  void _refreshClubs() {
    final SearchClubsCubit searchClubsCubit =
        BlocProvider.of<SearchClubsCubit>(context);

    clubsPage = 0;
    searchClubs = [];

    searchClubsCubit.searchClubs(0, searchTextController.text);
  }

  void _loadMoreClubs() {
    if (searchClubs!.length == 0) {
      _clubsRefreshController.loadComplete();
      return;
    }

    final SearchClubsCubit searchClubsCubit =
        BlocProvider.of<SearchClubsCubit>(context);

    searchClubsCubit.searchClubs(clubsPage + 1, searchTextController.text);
    clubsPage++;
  }

  void _clubBlocListener(context, state) {
    if (state is ClubsLoadedState) {
      if (_clubsRefreshController.isRefresh) {
        _scrollController.jumpTo(0.0);
        _clubsRefreshController.refreshCompleted();
        _clubsRefreshController.loadComplete();

        _clubsRefreshController = RefreshController(initialRefresh: false);
      } else if (_clubsRefreshController.isLoading) {
        if (state.hasReachedMax!)
          _clubsRefreshController.loadNoData();
        else
          _clubsRefreshController.loadComplete();
      }
    }
  }

  Widget _clubList() {
    return BlocConsumer<SearchClubsCubit, ClubsState>(
      listener: _clubBlocListener,
      builder: (context, searchClubsState) {
        if (searchClubsState is ClubsLoadedState)
          searchClubs = searchClubsState.clubs;

        if (searchClubsState is ClubsErrorState &&
            searchClubsState.error != AppError.REQUEST_CANCELLED)
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
            (searchClubsState is ClubsLoadingState && clubsPage == 0)
                ? _circularProgress()
                : Container(),
            Expanded(
              child: SmartRefresher(
                controller: _clubsRefreshController,
                header: CustomMaterialClassicHeader(),
                footer: ClassicFooter(
                  textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato'),
                  noDataText: "You've reached the end of the line",
                  failedText: "Something Went Wrong",
                ),
                onRefresh: _refreshClubs,
                onLoading: _loadMoreClubs,
                enablePullUp: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: searchClubs!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ClubItem(
                        club: searchClubs![index],
                        isFavourite: _favouritesClubsCubit
                            .checkClubExists(searchClubs![index]!.clubID),
                        onClubSelected: onClubSelected,
                      ),
                    );
                  },
                ),
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
}
