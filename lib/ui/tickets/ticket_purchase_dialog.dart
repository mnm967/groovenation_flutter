import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/state/ticket_purchase_state.dart';
import 'package:groovenation_flutter/cubit/state/tickets_state.dart';
import 'package:groovenation_flutter/cubit/tickets/ticket_purchase_cubit.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/ticket_price.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:intl/intl.dart';

class TicketPurchaseDialog extends StatefulWidget {
  final Event? event;
  TicketPurchaseDialog(this.event);

  @override
  _TicketPurchaseDialogState createState() => _TicketPurchaseDialogState(event);
}

class _TicketPurchaseDialogState extends State<TicketPurchaseDialog> {
  var publicKey = 'pk_test_e0bc926082eeaa6e1bff2f37c1c785a129642f0c';
  final plugin = PaystackPlugin();

  final Event? event;
  _TicketPurchaseDialogState(this.event);

  String? userPaymentReference;
  List<TicketPrice>? ticketPrices;

  _makePayment(BuildContext context) async {
    String paymentReference = _getReference();
    userPaymentReference = paymentReference;

    Charge charge = Charge()
      ..amount = (_calculateTicketTotalCost() * 100)
      ..currency = "ZAR"
      ..reference = paymentReference
      ..email = sharedPrefs.email;

    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );

    if (response.status) {
      final TicketPurchaseCubit ticketPurchaseCubit =
          BlocProvider.of<TicketPurchaseCubit>(context);

      ticketPurchaseCubit.verifyPurchase(context, event!.eventID, event!.clubID,
          selectedTicketType, selectedNoOfPeople, paymentReference);
    }
  }

  String _getReference() {
    return sharedPrefs.userId! +
        DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void initState() {
    super.initState();

    final TicketPurchaseCubit ticketPurchaseCubit =
        BlocProvider.of<TicketPurchaseCubit>(context);
    ticketPurchaseCubit.getTicketPrices(event!.eventID);

    plugin.initialize(publicKey: publicKey);
  }

  Widget _ticketError(state) {
    if (state.error == AppError.NETWORK_ERROR)
      return _purchaseStatusPage(
          BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Icons.error);
    else
      return _purchaseStatusPage(
          BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Icons.error);
  }

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> _sendAnalyticsEvent() async {
    analytics.logEvent(name: "ticket_purchase", parameters: <String, dynamic>{
      "event_id": event!.eventID,
      "event_name": event!.title,
      "club_id": event!.clubID == null ? event!.eventID : event!.clubID,
      "club_name": event!.clubName,
      "ticket_type": selectedTicketType.ticketType,
      "no_of_people": selectedNoOfPeople,
      "total_cost": _calculateTicketTotalCost(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: double.infinity,
        child: SizedBox.expand(
          child: Card(
              color: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: BlocConsumer<TicketPurchaseCubit, TicketPurchaseState>(
                  listener: (context, state) {
                if (state is TicketPurchasePricesLoadedState) {
                  ticketPrices = state.ticketPrices;
                  selectedTicketType = state.ticketPrices![0];
                  _checkTicketNum();
                }
              }, builder: (context, state) {
                if (state is TicketPurchasePricesLoadedState) {
                  if ((state).ticketPrices!.isEmpty) return _soldOutPage();
                }

                if (state is TicketPurchasePricesLoadingState ||
                    state is TicketsInitialState ||
                    state is TicketPurchaseLoadingState) {
                  return _purchaseProcessingPage();
                }

                if (state is TicketPurchasePricesErrorState)
                  _ticketError(state);
                if (state is TicketPurchaseErrorState) _ticketError(state);

                if (state is TicketPurchaseSuccessState) {
                  _sendAnalyticsEvent();

                  return _purchaseStatusPage(
                      "Purchase Successful",
                      "You've successfully purchased your ticket. \n\nWe hope you enjoy!!",
                      Icons.check);
                }

                return _ticketPurchasePage(context);
              })),
        ),
        margin: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
      ),
    );
  }

  _checkTicketNum() {
    switch (selectedTicketType.numAvailable) {
      case 0:
        items = [];
        numPeopleSelectedValue = items[0];
        selectedNoOfPeople = 0;
        break;
      case 1:
        items = ['1 Person'];
        numPeopleSelectedValue = items[0];
        selectedNoOfPeople = 1;
        break;
      case 2:
        items = ['1 Person', '2 People'];
        numPeopleSelectedValue = items[0];
        selectedNoOfPeople = 1;
        break;
      case 3:
        items = ['1 Person', '2 People', '3 People'];
        numPeopleSelectedValue = items[0];
        selectedNoOfPeople = 1;
        break;
      default:
        items = ['1 Person', '2 People', '3 People', '4 People'];
        numPeopleSelectedValue = items[0];
        selectedNoOfPeople = 1;
        break;
    }
  }

  Widget _purchaseProcessingPage() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor:
              new AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _purchaseStatusPage(String title, String text, IconData icon) {
    return Stack(
      children: [
        Container(
          child: Center(
            child: _statusContainer(icon, title, text),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 28,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _soldOutPage() {
    return Stack(
      children: [
        Container(
          child: Center(
            child: _soldOutContainer(),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 28,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _statusContainer(icon, title, text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints.expand(width: 108, height: 108),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 1.0, color: Colors.white),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 46.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 36, right: 16, left: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Lato', fontSize: 28),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontFamily: 'Lato',
                fontSize: 20),
          ),
        ),
        BlocBuilder<TicketPurchaseCubit, TicketPurchaseState>(
          builder: (context, state) {
            if (!(state is TicketPurchaseErrorState))
              return Padding(padding: EdgeInsets.zero);
            else
              return _tryAgainButton();
          },
        )
      ],
    );
  }

  Widget _soldOutContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints.expand(width: 108, height: 108),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 1.0, color: Colors.white),
          ),
          child: Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 46.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 36, right: 16, left: 16),
          child: Text(
            "Tickets Sold Out",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Lato', fontSize: 28),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Text(
            "Sorry, this event has sold out!!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontFamily: 'Lato',
                fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _tryAgainButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Center(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            final TicketPurchaseCubit ticketPurchaseCubit =
                BlocProvider.of<TicketPurchaseCubit>(context);

            ticketPurchaseCubit.verifyPurchase(
                context,
                event!.eventID,
                event!.clubID,
                selectedTicketType,
                selectedNoOfPeople,
                userPaymentReference);
          },
          child: Text(
            "Try Again",
            style: TextStyle(
                color: Colors.purple, fontFamily: 'Lato', fontSize: 17),
          ),
        ),
      ),
    );
  }

  int _calculateTicketTotalCost() {
    return selectedTicketType.price! * selectedNoOfPeople;
  }

  List<String?> items = <String?>[
    '1 Person',
    '2 People',
    '3 People',
    '4 People'
  ];
  String? numPeopleSelectedValue = '1 Person';

  late TicketPrice selectedTicketType;
  int selectedNoOfPeople = 1;

  Widget _ticketPurchasePage(context) {
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
            _header(),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            _ticketPageText("Event Club", event!.clubName),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            _ticketPageText(
                "Date",
                DateFormat("MMM dd, yyyy · HH:mm")
                    .format(event!.eventStartDate)),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            _ticketPageText("Tickets Currently Available",
                selectedTicketType.numAvailable == 0 ? "No" : "Yes"),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            _ticketPageText("Adults Only", event!.isAdultOnly! ? "Yes" : "No"),
            _ticketTypeDropdown(),
            _peopleDropdown(),
            Padding(
              padding: EdgeInsets.only(top: 48),
            ),
            _purchasePageText("Type", selectedTicketType.ticketType, false),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            _purchasePageText("No. of People",
                (items.indexOf(numPeopleSelectedValue) + 1).toString(), false),
            Padding(
              padding: EdgeInsets.only(top: 16),
            ),
            _purchasePageText("Total Price",
                "R" + _calculateTicketTotalCost().toString(), true),
            _purchaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: _ticketPageText("Event Name", event!.title))),
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
    );
  }

  Widget _peopleDropdown() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No. of People",
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: Colors.white.withOpacity(0.4)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, right: 8),
            child: Container(
              padding: EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Stack(
                children: [
                  DropdownButton<String>(
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 28,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    isExpanded: true,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        numPeopleSelectedValue = newValue;
                        selectedNoOfPeople = (items.indexOf(newValue) + 1);
                      });
                    },
                    itemHeight: 56,
                    value: numPeopleSelectedValue,
                    items: items.map<DropdownMenuItem<String>>((String? value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value!,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                color: Colors.deepPurple,
                                fontSize: 18)),
                      );
                    }).toList(),
                  ),
                  Container(
                    height: 56,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        numPeopleSelectedValue!,
                        style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _purchaseButton() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Padding(
        padding: EdgeInsets.only(top: 8, right: 8),
        child: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: TextButton(
            onPressed: () => _makePayment(context),
            child: Container(
              height: 56,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Purchase",
                  style: TextStyle(
                      fontFamily: 'LatoBold',
                      color: Colors.deepPurple,
                      fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticketTypeDropdown() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Type",
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                color: Colors.white.withOpacity(0.4)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, right: 8),
            child: Container(
              padding: EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Stack(
                children: [
                  DropdownButton<String>(
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 28,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    isExpanded: true,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTicketType = ticketPrices!.firstWhere(
                            (element) => element.ticketType == newValue);
                      });
                      _checkTicketNum();
                    },
                    itemHeight: 56,
                    value: selectedTicketType.ticketType,
                    items: ticketPrices!
                        .map<DropdownMenuItem<String>>((TicketPrice value) {
                      return DropdownMenuItem<String>(
                        value: value.ticketType,
                        child: Text(value.ticketType!,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                color: Colors.deepPurple,
                                fontSize: 18)),
                      );
                    }).toList(),
                  ),
                  Container(
                    height: 56,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedTicketType.ticketType!,
                        style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketPageText(title, text) {
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

  Widget _purchasePageText(title, text, isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: isBold ? 'LatoBlack' : 'Lato',
              fontSize: 20,
              color: Colors.white.withOpacity(0.4)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                text,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: isBold ? 'LatoBlack' : 'Lato',
                    fontSize: 22,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
