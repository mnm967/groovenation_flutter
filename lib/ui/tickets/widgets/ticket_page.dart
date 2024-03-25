import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TicketPage extends StatelessWidget {
  final GlobalKey globalKey = new GlobalKey();
  final Ticket? ticket;

  TicketPage({Key? key, this.ticket}) : super(key: key);

  Future<void> _captureAndSharePng(Ticket ticket) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      Share.shareFiles(['${tempDir.path}/image.png'],
          text:
              "${ticket.eventName}\n• ${ticket.ticketType}\n• ${ticket.noOfPeople! > 1 ? "•  " + ticket.noOfPeople.toString() + " People" : "•  1 Person"}• ${DateFormat("MMM dd, yyyy · HH:mm").format(ticket.startDate!)}");
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: double.infinity,
        child: SizedBox.expand(
          child: _ticketPage(context),
        ),
        margin: EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _ticketPage(context) {
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
            _header(context, ticket),
            Padding(padding: EdgeInsets.only(top: 16)),
            _ticketPageText("Event Club", ticket!.clubName),
            Padding(padding: EdgeInsets.only(top: 16)),
            _ticketPageText("Date",
                DateFormat("MMM dd, yyyy · HH:mm").format(ticket!.startDate!)),
            Padding(padding: EdgeInsets.only(top: 16)),
            _ticketPageText("Ticket ID", ticket!.ticketID),
            Padding(padding: EdgeInsets.only(top: 16)),
            _ticketPageText("Type", ticket!.ticketType),
            Padding(padding: EdgeInsets.only(top: 16)),
            _ticketPageText("No. of People", ticket!.noOfPeople.toString()),
            _ticketSummary(ticket),
            _qrImage(ticket)
          ],
        ),
      ),
    );
  }

  Widget _header(context, ticket) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: _ticketPageText("Event Name", ticket.eventName))),
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

  Widget _ticketSummary(ticket) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ticketCostText(),
          _shareButton(),
          _mapButton(),
        ],
      ),
    );
  }

  Widget _ticketCostText() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: _ticketPageText(
          "Cost",
          "R" + ticket!.totalCost.toString(),
        ),
      ),
    );
  }

  Widget _shareButton() {
    return RawMaterialButton(
      onPressed: () {
        _captureAndSharePng(ticket!);
      },
      constraints: BoxConstraints.expand(width: 56, height: 56),
      elevation: 0,
      child: Center(
        child: Icon(
          FontAwesomeIcons.shareAlt,
          color: Colors.white,
          size: 22.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white)),
    );
  }

  Widget _mapButton() {
    return RawMaterialButton(
      onPressed: () {
        MapsLauncher.launchCoordinates(
            ticket!.clubLatitude!, ticket!.clubLongitude!);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.mapMarkedAlt,
          color: Colors.white,
          size: 24.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white)),
    );
  }

  Widget _qrImage(ticket) {
    return Padding(
      padding: EdgeInsets.only(top: 36, bottom: 64),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        child: AspectRatio(
          aspectRatio: 1,
          child: RepaintBoundary(
              key: globalKey,
              child: QrImageView(
                data: ticket.encryptedQRTag,
                version: QrVersions.auto,
              )),
        ),
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
          ),
        ),
      ],
    );
  }
}
