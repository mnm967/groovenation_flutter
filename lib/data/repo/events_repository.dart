import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class EventsRepository {
  Future<bool> addFavouriteEvent(String eventId) async {
    String uid = sharedPrefs.userId.toString();

    try {
      Response response = await Dio()
          .get("$API_HOST/events/add/favourites/" + uid + "/" + eventId);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data);

        if (jsonResponse['status'] == 1) {
          bool isAdded = jsonResponse['result'];

          return isAdded;
        } else
          throw EventException(Error.UNKNOWN_ERROR);
      } else
        throw EventException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is EventException)
        throw EventException(e.error);
      else
        throw EventException(Error.NETWORK_ERROR);
    }
  }

  Future<bool> removeFavouriteEvent(String eventId) async {
    String uid = sharedPrefs.userId.toString();

    try {
      Response response = await Dio()
          .get("$API_HOST/events/remove/favourites/" + uid + "/" + eventId);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data);

        if (jsonResponse['status'] == 1) {
          bool isAdded = jsonResponse['result'];

          return isAdded;
        } else
          throw EventException(Error.UNKNOWN_ERROR);
      } else
        throw EventException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is EventException)
        throw EventException(e.error);
      else
        throw EventException(Error.NETWORK_ERROR);
    }
  }

  Future<APIResult> getFavouriteEvents() async {
    String uid = sharedPrefs.userId.toString();
    String userCity = sharedPrefs.userCity.toString();

    return getEvents("$API_HOST/events/favourites/" + uid + "/" + userCity);
  }

  Future<APIResult> getUpcomingEvents(int page) async {
    print(sharedPrefs.userCity.toString());
    print("page: " + page.toString());
    return getEvents("$API_HOST/events/upcoming/" +
        sharedPrefs.userCity.toString() +
        "/" +
        page.toString());
  }

  Future<APIResult> getClubEvents(int page, String clubId) async {
    return getEvents("$API_HOST/events/club/" + clubId + "/" + page.toString());
  }

  Future<APIResult> getEvents(String url) async {
    List<Event> events = [];

    try {
      Response response = await Dio().get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['events']) {
            Event event = Event.fromJson(i);
            events.add(event);
          }

          return APIResult(events, hasReachedMax);
        } else
          throw EventException(Error.UNKNOWN_ERROR);
      } else
        throw EventException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is EventException)
        throw EventException(e.error);
      else
        throw EventException(Error.NETWORK_ERROR);
    }
  }

  CancelToken _searchCancelToken;
  Future<APIResult> searchEvents(String searchTerm, int page) async {
    List<Event> events = [];

    if (_searchCancelToken != null) {
      try {
        _searchCancelToken.cancel();
        _searchCancelToken = null;
      } catch (e) {}
    }

    _searchCancelToken = CancelToken();

    try {
      Response response = await Dio().post("$API_HOST/events/search",
          data: {
            'search_term': searchTerm,
            'page': page,
            'user_city': sharedPrefs.userCity
          },
          cancelToken: _searchCancelToken);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['events']) {
            Event event = Event.fromJson(i);
            events.add(event);
          }

          return APIResult(events, hasReachedMax);
        } else
          throw EventException(Error.UNKNOWN_ERROR);
      } else
        throw EventException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is EventException)
        throw EventException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw EventException(Error.NETWORK_ERROR);
        else
          throw EventException(Error.NETWORK_ERROR);
      }
    }
  }
}

class EventException implements Exception {
  final Error error;
  EventException(this.error);
}
