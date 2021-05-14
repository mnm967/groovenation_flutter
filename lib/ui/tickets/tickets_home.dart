import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/tickets_state.dart';
import 'package:groovenation_flutter/cubit/tickets_cubit.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:optimized_cached_image/image_provider/optimized_cached_image_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

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

  runBuild() {
    if (_isFirstView) {
      print("Running Build: TicketsHome");
      _isFirstView = false;

      final TicketsCubit ticketsCubit = BlocProvider.of<TicketsCubit>(context);
      if (!(ticketsCubit is TicketsLoadedState)) ticketsCubit.getTickets();
    }
  }

  final _upcomingRefreshController = RefreshController(initialRefresh: true);
  final _completedRefreshController = RefreshController(initialRefresh: false);

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

  Column topAppBar() => Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                openSearchPage();
              },
              child: Container(
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
                            )),
                      ),
                    ],
                  ))),
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
        )
      ]);

  List<Ticket> upcoming = [];
  List<Ticket> completed = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketsCubit, TicketsState>(listener: (context, state) {
      if (state is TicketsLoadedState) {
        _upcomingRefreshController.refreshCompleted();
        _completedRefreshController.refreshCompleted();
      } else if (state is TicketsErrorState) {
        _upcomingRefreshController.refreshFailed();
        _completedRefreshController.refreshFailed();

        switch (state.error) {
          case Error.NETWORK_ERROR:
            alertUtil.sendAlert(BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT,
                Colors.red, Icons.error);
            break;
          default:
            alertUtil.sendAlert(BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT,
                Colors.red, Icons.error);
            break;
        }
      }
    }, builder: (context, ticketsState) {
      List<Ticket> up = ticketsState is TicketsLoadedState ? (ticketsState).tickets.where((ticket) {
          DateTime now = DateTime.now();
          return (now.isBefore(ticket.endDate) && !ticket.isScanned);
        }).toList() : [];

      if (ticketsState is TicketsLoadedState) {
        upcoming = ticketsState.tickets.where((ticket) {
          DateTime now = DateTime.now();
          return (now.isBefore(ticket.endDate) && !ticket.isScanned);
        }).toList();

        completed = ticketsState.tickets.where((ticket) {
          DateTime now = DateTime.now();
          return (now.isAfter(ticket.endDate) || ticket.isScanned);
        }).toList();

        print("upcoming: " + up.length.toString());
        print("completed: " + completed.length.toString());
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
                        TicketsList(up, false, _upcomingRefreshController,
                            () {
                          final TicketsCubit ticketsCubit =
                              BlocProvider.of<TicketsCubit>(context);

                          if ((ticketsCubit.state is TicketsLoadedState ||
                                  ticketsCubit.state is TicketsErrorState) &&
                              !_isFirstView) {
                            ticketsCubit.getTickets();
                          }
                        }),
                        TicketsList(
                            completed, true, _completedRefreshController, () {
                          final TicketsCubit ticketsCubit =
                              BlocProvider.of<TicketsCubit>(context);

                          if ((ticketsCubit.state is TicketsLoadedState ||
                                  ticketsCubit.state is TicketsErrorState) &&
                              !_isFirstView) {
                            ticketsCubit.getTickets();
                          }
                        }),
                      ],
                    ),
                  )
                ],
              )));
    });
  }
}

// class TicketsList extends StatefulWidget {
//   final List<Ticket> tickets;
//   final bool isCompleted;
//   final RefreshController refreshController;
//   final Function onRefresh;

//   TicketsList(
//       this.tickets, this.isCompleted, this.refreshController, this.onRefresh);

//   @override
//   _TicketsListState createState() {
//     print("len6:" + tickets.length.toString());
//     final _TicketsListState state =
//         _TicketsListState(tickets, isCompleted, refreshController, onRefresh);
//     return state;
//   }
// }

// class _TicketsListState extends State<TicketsList>
//     with AutomaticKeepAliveClientMixin<TicketsList> {
class TicketsList extends StatelessWidget {
  final List<Ticket> tickets;
  final bool isCompleted;
  final RefreshController refreshController;
  final Function onRefresh;

  TicketsList(
      this.tickets, this.isCompleted, this.refreshController, this.onRefresh);

  @override
  Widget build(BuildContext context) {

    return SmartRefresher(
      controller: refreshController,
      header: WaterDropMaterialHeader(),
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
      onRefresh: onRefresh,
      child: isCompleted ? completedList(tickets) : upcomingList(tickets),
    );
  }

  Widget upcomingList(List<Ticket> tickets) {
    List<Ticket> upcoming = tickets;

    print("mlen:" + tickets.length.toString());

    return ListView.builder(
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ticketItem(context, upcoming[index], false));
        });
  }

  Widget completedList(List<Ticket> tickets) {
    List<Ticket> completed = tickets;

    return ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        itemCount: completed.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ticketItem(context, completed[index], true));
        });
  }

  _showTicketPage(context, ticket) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.1),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (con, __, ___) {
        return SafeArea(
          bottom: false,
          child: Container(
            height: double.infinity,
            child: SizedBox.expand(
              child: ticketPage(con, ticket),
            ),
            margin: EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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

  Widget ticketItem(BuildContext context, Ticket ticket, bool isCompleted) {
    return Card(
      elevation: 6,
      color: Colors.deepPurple,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: FlatButton(
          onPressed: () {
            _showTicketPage(context, ticket);
          },
          padding: EdgeInsets.zero,
          child: Wrap(children: [
            Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 164,
                              width: 128,
                              child: Stack(
                                children: [
                                  Image(
                                    height: double.infinity,
                                    width: 128,
                                    fit: BoxFit.cover,
                                    image: OptimizedCacheImageProvider(
                                        ticket.imageUrl),
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(0.25),
                                    child: Center(
                                      child: new FaIcon(
                                        isCompleted
                                            ? FontAwesomeIcons.checkCircle
                                            : FontAwesomeIcons.qrcode,
                                        size: 72,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 20, top: 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.eventName,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'LatoBold',
                                        fontSize: 22,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: Colors.white),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                        ticket.clubName,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 18,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        DateFormat("MMM dd, yyyy · HH:mm")
                                            .format(ticket.startDate),
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        "• " + ticket.ticketType,
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        ticket.noOfPeople > 1
                                            ? "•  " +
                                                ticket.noOfPeople.toString() +
                                                " People"
                                            : "•  1 Person",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ],
            )
          ])),
    );
  }

  final GlobalKey globalKey = new GlobalKey();

  Future<void> _captureAndSharePng(Ticket ticket) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      Share.shareFiles(['${tempDir.path}/image.png'],
          text:
              "${ticket.eventName}\n• ${ticket.ticketType}\n• ${ticket.noOfPeople > 1 ? "•  " + ticket.noOfPeople.toString() + " People" : "•  1 Person"}• ${DateFormat("MMM dd, yyyy · HH:mm").format(ticket.startDate)}");

      // final channel = const MethodChannel('channel:me.alfian.share/share');
      // channel.invokeMethod('shareFile', 'image.png');

    } catch (e) {
      print(e.toString());
    }
  }

  Widget ticketPage(context, Ticket ticket) {
    return Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 24, bottom: 16, right: 16, left: 24),
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: ticketPageText(
                                "Event Name", ticket.eventName))),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Event Club", ticket.clubName),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText(
                      "Date",
                      DateFormat("MMM dd, yyyy · HH:mm")
                          .format(ticket.startDate)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Ticket ID", ticket.ticketID),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Type", ticket.ticketType),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText(
                      "No. of People", ticket.noOfPeople.toString()),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: ticketPageText(
                                  "Cost", "R" + ticket.totalCost.toString()))),
                      RawMaterialButton(
                        onPressed: () {
                          _captureAndSharePng(ticket);
                        },
                        constraints:
                            BoxConstraints.expand(width: 56, height: 56),
                        elevation: 0,
                        child: Center(
                            child: Icon(
                          FontAwesomeIcons.shareAlt,
                          color: Colors.white,
                          size: 22.0,
                        )),
                        padding: EdgeInsets.all(16.0),
                        shape: CircleBorder(
                            side: BorderSide(width: 1, color: Colors.white)),
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          MapsLauncher.launchCoordinates(
                              ticket.clubLatitude, ticket.clubLongitude);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        child: Center(
                            child: FaIcon(
                          FontAwesomeIcons.mapMarkedAlt,
                          color: Colors.white,
                          size: 24.0,
                        )),
                        padding: EdgeInsets.all(16.0),
                        shape: CircleBorder(
                            side: BorderSide(width: 1, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 36, bottom: 64),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: RepaintBoundary(
                            key: globalKey,
                            child: QrImage(
                              data: ticket.encryptedQRTag,
                              version: QrVersions.auto,
                            )),
                      ),
                    ))
              ]),
        ));
  }

  Widget ticketPageText(title, text) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: Colors.white.withOpacity(0.4)),
          ),
          Padding(
              padding: EdgeInsets.only(top: 1, right: 8),
              child: Text(
                text,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'LatoBold', fontSize: 20, color: Colors.white),
              )),
        ]);
  }

  // @override
  // bool get wantKeepAlive => true;
}
