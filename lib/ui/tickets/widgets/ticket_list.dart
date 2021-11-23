import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/ui/tickets/widgets/ticket_item.dart';
import 'package:groovenation_flutter/ui/tickets/widgets/ticket_page.dart';
import 'package:groovenation_flutter/widgets/custom_refresh_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TicketsList extends StatelessWidget {
  final List<Ticket?> tickets;
  final bool isCompleted;
  final RefreshController refreshController;
  final Function onRefresh;

  TicketsList(
      this.tickets, this.isCompleted, this.refreshController, this.onRefresh);

  void _onTicketPressed(BuildContext context, Ticket ticket) =>
      _showTicketPage(context, ticket);

  @override
  Widget build(BuildContext context) {
    return _smartRefresher();
  }

  Widget _smartRefresher() {
    return SmartRefresher(
      controller: refreshController,
      header: CustomMaterialClassicHeader(),
      footer: ClassicFooter(
        textStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
            fontFamily: 'Lato'),
        noDataText: "You've reached the end of the line",
        failedText: "Something Went Wrong",
      ),
      enablePullUp: false,
      enablePullDown: true,
      onRefresh: onRefresh as void Function()?,
      child: isCompleted
          ? _pastTicketsList(tickets)
          : _upcomingTicketsList(tickets),
    );
  }

  Widget _upcomingTicketsList(List<Ticket?> tickets) {
    List<Ticket?> upcoming = tickets;

    return ListView.builder(
      padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: upcoming.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TicketItem(
            ticket: upcoming[index],
            isCompleted: false,
            onTicketPressed: (context, ticket) =>
                _onTicketPressed(context, ticket),
          ),
        );
      },
    );
  }

  Widget _pastTicketsList(List<Ticket?> tickets) {
    List<Ticket?> completed = tickets;

    return ListView.builder(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TicketItem(
            ticket: completed[index],
            isCompleted: true,
            onTicketPressed: _onTicketPressed,
          ),
        );
      },
    );
  }

  _showTicketPage(context, ticket) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (con, __, ___) {
        return TicketPage(ticket: ticket);
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
              .animate(CurvedAnimation(parent: anim, curve: Curves.elasticOut)),
          child: child,
        );
      },
    );
  }
}
