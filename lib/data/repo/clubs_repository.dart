import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/util/network_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class ClubsRepository {
  CancelToken? _addReviewCancelToken;
  Future<bool?> addUserReview(String? clubId, num rating, String review) async {
    NetworkUtil.cancel(_addReviewCancelToken);

    _addReviewCancelToken = null;
    _addReviewCancelToken = CancelToken();

    String uid = sharedPrefs.userId.toString();

    String url = "$API_HOST/clubs/reviews/add";
    var body = {
      "userId": uid,
      "clubId": clubId,
      "rating": rating,
      "review": review,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        url, body, _onRequestError, _addReviewCancelToken);

    if (jsonResponse != null) return jsonResponse['result'];

    return null;
  }

  Future<bool?> addFavouriteClub(String? eventId) async {
    String uid = sharedPrefs.userId.toString();

    String url = "$API_HOST/clubs/add/favourites/$uid/$eventId";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) return jsonResponse['result'];

    return null;
  }

  Future<bool?> removeFavouriteClub(String? eventId) async {
    String uid = sharedPrefs.userId.toString();

    String url = "$API_HOST/clubs/remove/favourites/$uid/$eventId";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) return jsonResponse['result'];

    return null;
  }

  Future<APIResult?> getFavouriteClubs() async {
    return getClubs("$API_HOST/clubs/favourites/" +
        sharedPrefs.userId.toString() +
        "/" +
        sharedPrefs.userCity.toString());
  }

  Future<APIResult?> getTopRatedClubs(int page) async {
    return getClubs("$API_HOST/clubs/top/" +
        sharedPrefs.userId! +
        "/" +
        sharedPrefs.userCity! +
        "/" +
        page.toString());
  }

  Future<APIResult?> getNearbyClubs(int page, double? lat, double? lon) async {
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

  Future<APIResult?> getClubReviews(int page, String? clubId) async {
    String uid = sharedPrefs.userId.toString();

    List<ClubReview> clubReviews = [];

    String url = "$API_HOST/clubs/reviews/$clubId/$uid/${page.toString()}";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['club_reviews']) {
        ClubReview club = ClubReview.fromJson(i);
        clubReviews.add(club);
      }

      return APIResult(clubReviews, hasReachedMax);
    }

    return null;
  }

  Future<APIResult?> getClubs(String url) async {
    List<Club> clubs = [];

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['clubs']) {
        Club club = Club.fromJson(i, false);
        clubs.add(club);
      }

      return APIResult(clubs, hasReachedMax);
    }

    return null;
  }

  CancelToken? _searchCancelToken;
  Future<APIResult?> searchClubs(String searchTerm, int page) async {
    NetworkUtil.cancel(_searchCancelToken);

    _searchCancelToken = null;
    _searchCancelToken = CancelToken();

    List<Club> clubs = [];

    String url = "$API_HOST/clubs/search";
    var body = {
      'search_term': searchTerm,
      'page': page,
      'user_id': sharedPrefs.userId,
      'user_city': sharedPrefs.userCity
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        url, body, _onRequestError, _searchCancelToken);

    if (jsonResponse != "") {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['clubs']) {
        Club club = Club.fromJson(i, false);
        clubs.add(club);
      }

      return APIResult(clubs, hasReachedMax);
    }

    return null;
  }

  Future<Club?> getClub(String? clubId) async {
    String uid = sharedPrefs.userId.toString();
    String url = "$API_HOST/clubs/club/$clubId/$uid";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      Club club = Club.fromJson(jsonResponse['club'], false);
      return club;
    }

    return null;
  }

  _onRequestError(e) {
    if (e is ClubException)
      throw ClubException(e.error);
    else if (e is DioError) {
      if (e.type != DioErrorType.cancel)
        throw ClubException(AppError.NETWORK_ERROR);
      else
        throw ClubException(AppError.REQUEST_CANCELLED);
    } else
      throw ClubException(AppError.UNKNOWN_ERROR);
  }
}

class ClubException implements Exception {
  final AppError error;
  ClubException(this.error);
}
