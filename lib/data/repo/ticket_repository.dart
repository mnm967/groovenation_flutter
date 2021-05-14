import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/models/ticket_price.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class TicketsRepository {
  Future<List<Ticket>> getUserTickets() async {
    List<Ticket> tickets = [];

    try {
      Response response =
          await Dio().get("$API_HOST/tickets/" + sharedPrefs.userId);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          for (Map i in jsonResponse['tickets']) {
            Ticket ticket = Ticket.fromJson(i);
            tickets.add(ticket);
          }

          return tickets;
        } else
          throw TicketException(Error.UNKNOWN_ERROR);
      } else
        throw TicketException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is TicketException)
        throw TicketException(e.error);
      else
        throw TicketException(Error.NETWORK_ERROR);
    }
  }

  Future<List<TicketPrice>> getTicketPrices(String eventId) async {
    List<TicketPrice> ticketPrices = [];

    try {
      Response response =
          await Dio().get("$API_HOST/tickets/prices/" + eventId);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          for (Map i in jsonResponse['ticket_prices']) {
            TicketPrice ticketPrice = TicketPrice.fromJson(i);
            ticketPrices.add(ticketPrice);
          }

          return ticketPrices;
        } else
          throw TicketException(Error.UNKNOWN_ERROR);
      } else
        throw TicketException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is TicketException)
        throw TicketException(e.error);
      else
        throw TicketException(Error.NETWORK_ERROR);
    }
  }

  Future<Ticket> verifyTicketPurchase(String eventId, String clubId,
      TicketPrice ticketType, int noOfPeople, String reference) async {
    String uid = sharedPrefs.userId;
    try {
      Response response = await Dio().post("$API_HOST/tickets/purchase/verify",
          data: {
            "userId": uid,
            "eventId": eventId,
            "clubId": clubId,
            "paymentReference": reference,
            "ticketPrice": ticketType.price,
            "ticketType": ticketType.ticketType,
            "ticketNumAvailable": ticketType.numAvailable,
            "noOfPeople": noOfPeople,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          if (jsonResponse['result'] == INVALID_PURCHASE_REFERENCE)
            throw TicketPurchaseException(Error.INVALID_PURCHASE_REFERENCE);
          else if (jsonResponse['result'] == TRANSACTION_NOT_SUCCESSFUL)
            throw TicketPurchaseException(Error.TRANSACTION_NOT_SUCCESSFUL);
          else
            return Ticket.fromJson(jsonResponse['result']);
        } else
          throw TicketPurchaseException(Error.UNKNOWN_ERROR);
      } else
        throw TicketPurchaseException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is TicketPurchaseException)
        throw TicketPurchaseException(e.error);
      else
        throw TicketPurchaseException(Error.NETWORK_ERROR);
    }
  }
}

class TicketException implements Exception {
  final Error error;
  TicketException(this.error);
}

class TicketPurchaseException implements Exception {
  final Error error;
  TicketPurchaseException(this.error);
}
