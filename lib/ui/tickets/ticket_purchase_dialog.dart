import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TicketPurchaseDialog extends StatefulWidget {
  @override
  _TicketPurchaseDialogState createState() => _TicketPurchaseDialogState();
}

class _TicketPurchaseDialogState extends State<TicketPurchaseDialog> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: double.infinity,
        child: SizedBox.expand(
          child: Card(
            color: Colors.deepPurple,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ticketPurchasePage(),
          ),
        ),
        margin: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
      ),
    );
  }

  Widget purchaseProcessingPage() {
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

  Widget purchaseStatusPage() {
    return Stack(
      children: [
        Container(
          child: Center(
              child: Column(
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
                  Icons.check,
                  color: Colors.white,
                  size: 46.0,
                )),
              ),
              Padding(
                padding: EdgeInsets.only(top: 36, right: 16, left: 16),
                child: Text(
                  "Purchase Successful",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Lato', fontSize: 36),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Text(
                  "You've successfully purchased your ticket for Helix After Party. Hope you enjoy!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontFamily: 'Lato', fontSize: 24),
                ),
              ),
            ],
          )),
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
            ))
      ],
    );
  }

  final List<String> items = <String>[
    '1 Person',
    '2 People',
    '3 People',
    '4 People'
  ];
  String dropdownValue = '1 Person';

  final List<String> typeItems = <String>[
    'General Admission',
    'Special Admission',
    'VIP Admission',
    'Golden Circle'
  ];
  String typeValue = 'Special Admission';

  Widget ticketPurchasePage() {
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
                                "Event Name", "Helix After Party"))),
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
                  child: ticketPageText("Event Club", "Jive Lounge"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Date", "Sep 19, 2020 · 20:00"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Tickets Currently Available", "4"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ticketPageText("Adults Only", "Yes"),
                ),
                Padding(
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
                                border:
                                    Border.all(width: 1.0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Stack(
                                children: [
                                  DropdownButton<String>(
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                    iconSize: 28,
                                    elevation: 16,
                                    style: TextStyle(color: Colors.deepPurple),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 0,
                                      color: Colors.transparent,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        typeValue = newValue;
                                        print(typeValue);
                                      });
                                    },
                                    itemHeight: 56,
                                    value: typeValue,
                                    items: typeItems
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
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
                                        typeValue,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ]),
                ),
                Padding(
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
                                border:
                                    Border.all(width: 1.0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Stack(
                                children: [
                                  DropdownButton<String>(
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                    iconSize: 28,
                                    elevation: 16,
                                    style: TextStyle(color: Colors.deepPurple),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 0,
                                      color: Colors.transparent,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue = newValue;
                                        print(dropdownValue);
                                      });
                                    },
                                    itemHeight: 56,
                                    value: dropdownValue,
                                    items: items.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
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
                                        dropdownValue,
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: purchasePageText("Type", "General Admission", false),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: purchasePageText("No. of People", "1", false),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: purchasePageText("Total Price", "R500", true),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: FlatButton(
                          onPressed: () {},
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
                              )),
                        ),
                      )),
                ),
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

  Widget purchasePageText(title, text, isBold) {
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
                      )))),
        ]);
  }
}
