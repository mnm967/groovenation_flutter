import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/util/network_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class EventsRepository {
  Future<bool?> addFavouriteEvent(String? eventId) async {
    String uid = sharedPrefs.userId.toString();

    String url = "$API_HOST/events/add/favourites/$uid/$eventId";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) return jsonResponse['result'];

    return null;
  }

  Future<bool?> removeFavouriteEvent(String? eventId) async {
    String uid = sharedPrefs.userId.toString();

    String url = "$API_HOST/events/remove/favourites/$uid/$eventId";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) return jsonResponse['result'];

    return null;
  }

  Future<APIResult?> getFavouriteEvents() async {
    String uid = sharedPrefs.userId.toString();
    String userCity = sharedPrefs.userCity.toString();

    return getEvents("$API_HOST/events/favourites/" + uid + "/" + userCity);
  }

  Future<APIResult?> getUpcomingEvents(int page) async {
    return getEvents("$API_HOST/events/upcoming/" +
        sharedPrefs.userCity.toString() +
        "/" +
        page.toString());
  }

  Future<APIResult?> getClubEvents(int page, String clubId) async {
    return getEvents("$API_HOST/events/club/" + clubId + "/" + page.toString());
  }

  Future<APIResult?> getEvents(String url) async {
    List<Event> events = [];

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['events']) {
        Event event = Event.fromJson(i);
        events.add(event);
      }

      return APIResult(events, hasReachedMax);
    }

    return null;
  }

  CancelToken? _searchCancelToken;
  Future<APIResult?> searchEvents(String searchTerm, int page) async {
    NetworkUtil.cancel(_searchCancelToken);

    _searchCancelToken = null;
    _searchCancelToken = CancelToken();

    List<Event> events = [];

    String url = "$API_HOST/events/search";
    var body = {
      'search_term': searchTerm,
      'page': page,
      'user_city': sharedPrefs.userCity
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        url, body, _onRequestError, _searchCancelToken);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['events']) {
        Event event = Event.fromJson(i);
        events.add(event);
      }

      return APIResult(events, hasReachedMax);
    }

    return null;
  }

  _onRequestError(e) {
    if (e is EventException)
      throw EventException(e.error);
    else if (e is DioError) {
      if (e.type != DioErrorType.cancel)
        throw EventException(AppError.NETWORK_ERROR);
      else
        throw EventException(AppError.REQUEST_CANCELLED);
    } else
      throw EventException(AppError.UNKNOWN_ERROR);
  }
}

class EventException implements Exception {
  final AppError error;
  EventException(this.error);
}
