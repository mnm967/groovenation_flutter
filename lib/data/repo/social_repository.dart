import 'package:crypt/crypt.dart';
import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/util/network_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:path/path.dart' as p;

import 'package:random_string/random_string.dart';

class SocialRepository {
  Future<APIResult?> getNearbySocialPosts(
      int page, double? lat, double? lon) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/nearby/$uid/$lat/$lon/$page");
  }

  Future<APIResult?> getFollowingSocialPosts(int page) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/following/$uid/$page");
  }

  Future<APIResult?> getClubSocialPosts(page, clubId) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/profile/$clubId/$uid/$page");
  }

  Future<APIResult?> getTrendingSocialPosts(int page) async {
    print(page);
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/trending/$uid/$page");
  }

  Future<APIResult?> getProfileSocialPosts(int page, String? profileId) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/profile/$profileId/$uid/$page");
  }

  Future<APIResult?> getSocialPosts(String url) async {
    List<SocialPost> socialPosts = [];

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['social_posts']) {
        SocialPost socialPost = SocialPost.fromJson(i);
        socialPosts.add(socialPost);
      }

      return APIResult(socialPosts, hasReachedMax);
    }

    return null;
  }

  Future<APIResult?> getSocialComments(int page, String? postID) async {
    var uid = sharedPrefs.userId;
    List<SocialComment> socialComments = [];

    String url = "$API_HOST/social/post/comments/$uid/$postID/$page";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['social_comments']) {
        SocialComment socialComment = SocialComment.fromJson(i);
        socialComments.add(socialComment);
      }

      return APIResult(socialComments, hasReachedMax);
    }

    return null;
  }

  Future<SocialPost?> uploadSocialPost(String mediaFilePath, String caption,
      String? clubId, bool? isVideo) async {
    var uid = sharedPrefs.userId;

    String url = "$API_HOST/social/post/create";

    FormData formData = new FormData.fromMap({
      "user_id": uid,
      "caption": caption,
      "club_id": clubId,
      "social_file": await MultipartFile.fromFile(mediaFilePath,
          filename: randomAlphaNumeric(15) +
              DateTime.now().millisecondsSinceEpoch.toString() +
              p.extension(mediaFilePath)),
    });

    var jsonResponse = await NetworkUtil.executePostRequest(url, formData,
        _onRequestError, null, Options(contentType: 'multipart/form-data', headers: {}));

    if (jsonResponse != null) {
      if (jsonResponse['social_post'] != null) {
        SocialPost post = SocialPost.fromJson(jsonResponse['social_post']);
        return post;
      }
    }

    return null;
  }

  CancelToken? _searchCancelToken;
  Future<APIResult?> searchUsers(String searchTerm, int page) async {
    NetworkUtil.cancel(_searchCancelToken);

    _searchCancelToken = null;
    _searchCancelToken = CancelToken();

    List<SocialPerson> people = [];

    String url = "$API_HOST/social/search/users";
    var body = {
      'search_term': searchTerm,
      'page': page,
      'user_id': sharedPrefs.userId,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        url, body, _onRequestError, _searchCancelToken);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['social_people']) {
        SocialPerson person = SocialPerson.fromJson(i);
        people.add(person);
      }

      return APIResult(people, hasReachedMax);
    }

    return null;
  }

  Future<bool?> updateProfileSettings(String? userId, String email,
      String? newProfileImagePath, String? newCoverImagePath) async {
    FormData formData = new FormData.fromMap({
      "userId": userId,
      "email": email,
      "previousProfileUrl": sharedPrefs.profilePicUrl,
      "previousCoverUrl": sharedPrefs.coverPicUrl,
      "profile_image": newProfileImagePath != null
          ? await MultipartFile.fromFile(newProfileImagePath,
              filename: randomAlphaNumeric(15) +
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  p.extension(newProfileImagePath))
          : null,
      "cover_image": newCoverImagePath != null
          ? await MultipartFile.fromFile(newCoverImagePath,
              filename: randomAlphaNumeric(15) +
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  p.extension(newCoverImagePath))
          : null,
    });

    var jsonResponse = await NetworkUtil.executePostRequest(
        "$API_HOST/social/profile/update",
        formData,
        _onRequestError,
        null,
        Options(contentType: 'multipart/form-data', headers: {}));

    if (jsonResponse != null) {
      if (jsonResponse['result']) {
        sharedPrefs.profilePicUrl = jsonResponse['profileUrl'];
        sharedPrefs.coverPicUrl = jsonResponse['coverUrl'];
      }

      return jsonResponse['result'];
    }

    return null;
  }

  Future<bool?> changeUserPassword(
      String? userId, String oldPassword, String newPassword) async {
    final c1 =
        Crypt.sha256(oldPassword, rounds: 10000, salt: PASSWORD_SHA_SALT);
    final c2 =
        Crypt.sha256(newPassword, rounds: 10000, salt: PASSWORD_SHA_SALT);

    var body = {
      "userId": userId,
      "oldPassword": c1.hash,
      "newPassword": c2.hash,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        "$API_HOST/social/profile/password/change", body, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['status'] == 1) {
        return jsonResponse['is_success'];
      } else if (jsonResponse['status'] == -2) {
        throw SocialException(AppError.INCORRECT_OLD_PASSWORD);
      }
    }

    return null;
  }

  Future<APIResult?> getUserFollowing(int page, String? userID) async {
    List<SocialPerson> socialPeople = [];

    var jsonResponse = await NetworkUtil.executeGetRequest(
        "$API_HOST/social/users/following/$userID/$page", _onRequestError);
    print(jsonResponse);
    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['social_people']) {
        SocialPerson socialPerson = SocialPerson.fromJson(i);
        socialPeople.add(socialPerson);
      }

      return APIResult(socialPeople, hasReachedMax);
    }

    return APIResult([], true);
  }

  CancelToken? _searchFollowingToken;
  Future<APIResult?> searchUserFollowing(
      int page, String? userID, String searchTerm) async {
    NetworkUtil.cancel(_searchFollowingToken);

    _searchFollowingToken = null;
    _searchFollowingToken = CancelToken();

    List<SocialPerson> socialPeople = [];

    var body = {
      "search_term": searchTerm,
      "page": page,
      "user_id": userID,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        "$API_HOST/social/users/following/search", body, (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else if (e is DioError) {
        if (e.type != DioErrorType.cancel)
          throw SocialException(AppError.NETWORK_ERROR);
        else
          return null;
      } else
        throw SocialException(AppError.UNKNOWN_ERROR);
    }, _searchFollowingToken);

    if (jsonResponse != null) {
      bool? hasReachedMax = jsonResponse['has_reached_max'];

      for (Map i in jsonResponse['social_people']) {
        SocialPerson socialPerson = SocialPerson.fromJson(i);
        socialPeople.add(socialPerson);
      }

      return APIResult(socialPeople, hasReachedMax);
    }

    return null;
  }

  Future<bool?> changeLikeSocialPost(SocialPost post) async {
    var uid = sharedPrefs.userId;

    String url = post.hasUserLiked!
        ? "$API_HOST/social/post/like"
        : "$API_HOST/social/post/unlike";
    var body = {
      "user_id": uid,
      "post_id": post.postID,
    };

    var jsonResponse =
        await NetworkUtil.executePostRequest(url, body, _onRequestError);

    if (jsonResponse != null) return true;

    return null;
  }

  Future<bool?> changeUserFollowing(SocialPerson person) async {
    var uid = sharedPrefs.userId;

    String url = person.isUserFollowing!
        ? "$API_HOST/social/follow/${person.personID}/$uid"
        : "$API_HOST/social/unfollow/${person.personID}/$uid";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) return true;

    return null;
  }

  Future<bool?> changeLikeComment(SocialComment comment) async {
    var uid = sharedPrefs.userId;

    String url = comment.hasUserLiked!
        ? "$API_HOST/social/post/comment/like"
        : "$API_HOST/social/post/comment/unlike";

    var body = {
      "user_id": uid,
      "comment_id": comment.commentId,
    };

    var jsonResponse =
        await NetworkUtil.executePostRequest(url, body, _onRequestError);

    if (jsonResponse != null) return true;

    return null;
  }

  Future<bool?> addSocialComment(String? postId, String comment) async {
    var uid = sharedPrefs.userId;

    var body = {
      "user_id": uid,
      "post_id": postId,
      "comment": comment,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        "$API_HOST/social/post/comment/add", body, _onRequestError);

    if (jsonResponse != null) return true;

    return null;
  }

  Future<bool?> sendReport(String? reportType, String comment, SocialPost? post,
      SocialPerson? person) async {
    var body = {
      "report_type": reportType,
      "report_comment": comment,
      "report_user": person != null ? person.personID : null,
      "report_post": post != null ? post.postID : null,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        "$API_HOST/social/report", body, _onRequestError);

    if (jsonResponse != null) return true;

    return null;
  }

  Future<bool?> changeUserBlock(String? personId, bool isBlocked) async {
    var uid = sharedPrefs.userId;

    String url = isBlocked
        ? "$API_HOST/social/block/$uid/$personId"
        : "$API_HOST/social/unblock/$uid/$personId";

    var jsonResponse =
        await NetworkUtil.executeGetRequest(url, _onRequestError);

    if (jsonResponse != null) return true;

    return null;
  }

  _onRequestError(e) {
    if (e is SocialException)
      throw SocialException(e.error);
    else if (e is DioError){
      if (e.type != DioErrorType.cancel)
        throw SocialException(AppError.NETWORK_ERROR);
      else
        throw SocialException(AppError.REQUEST_CANCELLED);
    }else
      throw SocialException(AppError.UNKNOWN_ERROR);
  }
}

class SocialException implements Exception {
  final AppError error;
  SocialException(this.error);
}
