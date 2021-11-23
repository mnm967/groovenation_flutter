import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/ticket.dart';
import 'package:groovenation_flutter/models/ticket_price.dart';
import 'package:groovenation_flutter/util/network_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class TicketsRepository {
  Future<List<Ticket>?> getUserTickets() async {
    List<Ticket> tickets = [];

    var jsonResponse = await NetworkUtil.executeGetRequest(
        "$API_HOST/tickets/${sharedPrefs.userId}", _onRequestError);

    if (jsonResponse != null) {
      for (Map i in jsonResponse['tickets']) {
        Ticket ticket = Ticket.fromJson(i);
        tickets.add(ticket);
      }

      return tickets;
    }

    return null;
  }

  Future<List<TicketPrice>?> getTicketPrices(String? eventId) async {
    List<TicketPrice> ticketPrices = [];

    var jsonResponse = await NetworkUtil.executeGetRequest(
        "$API_HOST/tickets/prices/$eventId", _onRequestError);

    if (jsonResponse != null) {
      for (Map i in jsonResponse['ticket_prices']) {
        TicketPrice ticketPrice = TicketPrice.fromJson(i);
        ticketPrices.add(ticketPrice);
      }

      return ticketPrices;
    }

    return null;
  }

  Future<Ticket?> verifyTicketPurchase(String? eventId, String? clubId,
      TicketPrice ticketType, int noOfPeople, String? reference) async {
    String? uid = sharedPrefs.userId;

    var body = {
      "userId": uid,
      "eventId": eventId,
      "clubId": clubId,
      "paymentReference": reference,
      "ticketPrice": ticketType.price,
      "ticketType": ticketType.ticketType,
      "ticketNumAvailable": ticketType.numAvailable,
      "noOfPeople": noOfPeople,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        "$API_HOST/tickets/purchase/verify", body, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['result'] == INVALID_PURCHASE_REFERENCE)
        throw TicketException(AppError.INVALID_PURCHASE_REFERENCE);
      else if (jsonResponse['result'] == TRANSACTION_NOT_SUCCESSFUL)
        throw TicketException(AppError.TRANSACTION_NOT_SUCCESSFUL);
      else
        return Ticket.fromJson(jsonResponse['result']);
    }

    return null;
  }

  _onRequestError(e) {
    if (e is TicketException)
      throw TicketException(e.error);
    else if (e is DioError) if (e.type != DioErrorType.cancel)
      throw TicketException(AppError.NETWORK_ERROR);
    else
      throw TicketException(AppError.UNKNOWN_ERROR);
  }
}

class TicketException implements Exception {
  final AppError error;
  TicketException(this.error);
}
