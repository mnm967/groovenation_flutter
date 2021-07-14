import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class ClubsRepository {
  CancelToken _addReviewCancelToken;
  Future<bool> addUserReview(String clubId, num rating, String review) async {
    String uid = sharedPrefs.userId.toString();

    Map<String, dynamic> json = {
      "userId": uid,
      "clubId": clubId,
      "rating": rating,
      "review": review,
    };

    if (_addReviewCancelToken != null) _addReviewCancelToken.cancel();

    _addReviewCancelToken = CancelToken();

    try {
      Response response = await Dio().post("$API_HOST/clubs/reviews/add",
          data: json,
          cancelToken: _addReviewCancelToken,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print("add response: " + response.data.toString());

        if (jsonResponse['status'] == 1) {
          return jsonResponse['result'];
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print("err: " + e.toString());

      if (e is ClubException)
        throw ClubException(e.error);
      else
        throw ClubException(Error.UNKNOWN_ERROR);
    }
  }

  Future<bool> addFavouriteClub(String eventId) async {
    String uid = sharedPrefs.userId.toString();

    try {
      Response response = await Dio()
          .get("$API_HOST/clubs/add/favourites/" + uid + "/" + eventId);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool isAdded = jsonResponse['result'];

          return isAdded;
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ClubException)
        throw ClubException(e.error);
      else
        throw ClubException(Error.NETWORK_ERROR);
    }
  }

  Future<bool> removeFavouriteClub(String eventId) async {
    String uid = sharedPrefs.userId.toString();

    try {
      Response response = await Dio()
          .get("$API_HOST/clubs/remove/favourites/" + uid + "/" + eventId);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool isAdded = jsonResponse['result'];

          return isAdded;
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ClubException)
        throw ClubException(e.error);
      else
        throw ClubException(Error.NETWORK_ERROR);
    }
  }

  Future<APIResult> getFavouriteClubs() async {
    return getClubs("$API_HOST/clubs/favourites/" +
        sharedPrefs.userId.toString() +
        "/" +
        sharedPrefs.userCity.toString());
  }

  Future<APIResult> getTopRatedClubs(int page) async {
    print("tpage: " + page.toString());
    return getClubs(
        "$API_HOST/clubs/top/" + sharedPrefs.userId + "/" + page.toString());
  }

  Future<APIResult> getNearbyClubs(int page, double lat, double lon) async {
    print("page: " + page.toString());
    print("url: " +
        "$API_HOST/clubs/nearby/" +
        sharedPrefs.userId.toString() +
        "/" +
        lat.toString() +
        "/" +
        lon.toString() +
        "/" +
        sharedPrefs.userCity.toString() +
        "/" +
        page.toString());

    return getClubs("$API_HOST/clubs/nearby/" +
        sharedPrefs.userId.toString() +
        "/" +
        lat.toString() +
        "/" +
        lon.toString() +
        "/" +
        sharedPrefs.userCity.toString() +
        "/" +
        page.toString());
  }

  Future<APIResult> getClubReviews(int page, String clubId) async {
    String uid = sharedPrefs.userId.toString();

    List<ClubReview> clubReviews = [];

    try {
      Response response = await Dio().get("$API_HOST/clubs/reviews/" +
          clubId +
          "/" +
          uid +
          "/" +
          page.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['club_reviews']) {
            ClubReview club = ClubReview.fromJson(i);
            clubReviews.add(club);
          }

          return APIResult(clubReviews, hasReachedMax);
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is ClubException)
        throw ClubException(e.error);
      else
        throw ClubException(Error.NETWORK_ERROR);
    }
  }

  Future<APIResult> getClubs(String url) async {
    List<Club> clubs = [];

    try {
      Response response = await Dio().get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data);

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['clubs']) {
            Club club = Club.fromJson(i, false);
            clubs.add(club);
          }

          return APIResult(clubs, hasReachedMax);
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is ClubException)
        throw ClubException(e.error);
      else
        throw ClubException(Error.NETWORK_ERROR);
    }
  }

  CancelToken _searchCancelToken;
  Future<APIResult> searchClubs(String searchTerm, int page) async {
    List<Club> clubs = [];

    if (_searchCancelToken != null) {
      try {
        _searchCancelToken.cancel();
        _searchCancelToken = null;
      } catch (e) {}
    }

    _searchCancelToken = CancelToken();

    try {
      Response response = await Dio().post("$API_HOST/clubs/search",
          data: {
            'search_term': searchTerm,
            'page': page,
            'user_id': sharedPrefs.userId,
            'user_city': sharedPrefs.userCity
          },
          cancelToken: _searchCancelToken);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data);

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['clubs']) {
            Club club = Club.fromJson(i, false);
            clubs.add(club);
          }

          return APIResult(clubs, hasReachedMax);
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is ClubException)
        throw ClubException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw ClubException(Error.NETWORK_ERROR);
        else
          throw ClubException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<Club> getClub(String clubId) async {
    String uid = sharedPrefs.userId.toString();

    try {
      Response response =
          await Dio().get("$API_HOST/clubs/club/" + clubId + "/" + uid);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data);

        if (jsonResponse['status'] == 1) {
          Club club = Club.fromJson(jsonResponse['club'], false);
          return club;
        } else
          throw ClubException(Error.UNKNOWN_ERROR);
      } else
        throw ClubException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is ClubException)
        throw ClubException(e.error);
      else
        throw ClubException(Error.NETWORK_ERROR);
    }
  }
}

class ClubException implements Exception {
  final Error error;
  ClubException(this.error);
}
