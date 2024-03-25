import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/tickets_state.dart';
import 'package:groovenation_flutter/cubit/tickets/tickets_cubit.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/ui/tickets/widgets/ticket_list.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TicketsHomePage extends StatefulWidget {
  final _TicketsHomePageState state = _TicketsHomePageState();

  void runBuild() {
    state.runBuild();
  }

  @override
  _TicketsHomePageState createState() {
    return state;
  }
}

class _TicketsHomePageState extends State<TicketsHomePage> {
  bool _isFirstView = true;
  final _upcomingRefreshController = RefreshController(initialRefresh: true);
  final _completedRefreshController = RefreshController(initialRefresh: false);

  void runBuild() {
    if (_isFirstView) {
      print("Running Build: TicketsHome");
      _isFirstView = false;

      final TicketsCubit ticketsCubit = BlocProvider.of<TicketsCubit>(context);
      if (!(ticketsCubit is TicketsLoadedState)) ticketsCubit.getTickets();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _upcomingRefreshController.dispose();
    _completedRefreshController.dispose();
    super.dispose();
  }

  openSearchPage() {
    Navigator.pushNamed(context, '/search');
  }

  Widget topAppBar() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: TextButton(
            onPressed: () {
              openSearchPage();
            },
            child: _appBarSearch(),
          ),
        ),
        TabBar(
          tabs: [
            Tab(
              icon: Icon(FontAwesomeIcons.ticketAlt),
              text: "Upcoming",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.checkCircle),
              text: "Past",
            ),
          ],
        ),
      ],
    );
  }

  Widget _appBarSearch() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.2)),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text(
                "Search",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Lato',
                    fontSize: 17),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 24),
              child: Icon(
                Icons.search,
                size: 28,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Ticket?> upcoming = [];
  List<Ticket?> completed = [];

  void _blocListener(context, state) {
    if (state is TicketsLoadedState) {
      _upcomingRefreshController.refreshCompleted();
      _completedRefreshController.refreshCompleted();
    } else if (state is TicketsErrorState) {
      _upcomingRefreshController.refreshFailed();
      _completedRefreshController.refreshFailed();

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

  void _upcomingRefresh() {
    final TicketsCubit ticketsCubit = BlocProvider.of<TicketsCubit>(context);

    if ((ticketsCubit.state is TicketsLoadedState ||
            ticketsCubit.state is TicketsErrorState) &&
        !_isFirstView) {
      ticketsCubit.getTickets();
    }
  }

  void _completedRefresh() {
    final TicketsCubit ticketsCubit = BlocProvider.of<TicketsCubit>(context);

    if ((ticketsCubit.state is TicketsLoadedState ||
            ticketsCubit.state is TicketsErrorState) &&
        !_isFirstView) {
      ticketsCubit.getTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketsCubit, TicketsState>(
      listener: _blocListener,
      builder: (context, ticketsState) {
        if (ticketsState is TicketsLoadedState) {
          upcoming = (ticketsState).tickets!.where((ticket) {
            DateTime now = DateTime.now();
            return (now.isBefore(ticket!.endDate!) && !ticket.isScanned!);
          }).toList();

          completed = ticketsState.tickets!.where((ticket) {
            DateTime now = DateTime.now();
            return (now.isAfter(ticket!.endDate!) || ticket.isScanned!);
          }).toList();
        }

        return SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                topAppBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      TicketsList(upcoming, false, _upcomingRefreshController,
                          _upcomingRefresh),
                      TicketsList(completed, true, _completedRefreshController,
                          _completedRefresh),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
