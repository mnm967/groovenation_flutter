import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/api_result.dart';
import 'package:groovenation_flutter/models/social_comment.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:path/path.dart' as p;

import 'package:random_string/random_string.dart';

class SocialRepository {
  Future<APIResult> getNearbySocialPosts(
      int page, double lat, double lon) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/nearby/$uid/$lat/$lon/$page");
  }

  Future<APIResult> getFollowingSocialPosts(int page) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/following/$uid/$page");
  }

  Future<APIResult> getClubSocialPosts(page, clubId) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/profile/$clubId/$uid/$page");
  }

  Future<APIResult> getTrendingSocialPosts(int page) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/trending/$uid/$page");
  }

  Future<APIResult> getProfileSocialPosts(int page, String profileId) async {
    var uid = sharedPrefs.userId;
    return getSocialPosts("$API_HOST/social/profile/$profileId/$uid/$page");
  }

  Future<APIResult> getSocialPosts(String url) async {
    List<SocialPost> socialPosts = [];

    try {
      Response response = await Dio().get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['social_posts']) {
            SocialPost socialPost = SocialPost.fromJson(i);
            socialPosts.add(socialPost);
          }

          return APIResult(socialPosts, hasReachedMax);
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else
        throw SocialException(Error.NETWORK_ERROR);
    }
  }

  Future<APIResult> getSocialComments(int page, String postID) async {
    var uid = sharedPrefs.userId;
    List<SocialComment> socialComments = [];

    try {
      Response response =
          await Dio().get("$API_HOST/social/post/comments/$uid/$postID");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['social_comments']) {
            SocialComment socialComment = SocialComment.fromJson(i);
            socialComments.add(socialComment);
          }

          return APIResult(socialComments, hasReachedMax);
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else
        throw SocialException(Error.NETWORK_ERROR);
    }
  }

  Future<bool> updateProfileSettings(String userId, String email,
      String newProfileImagePath, String newCoverImagePath) async {
    try {
      FormData formData = new FormData.fromMap({
        "userId": userId,
        "email": email,
        "profile_image": newProfileImagePath != null
            ? await MultipartFile.fromFile(newProfileImagePath,
                filename: randomAlphaNumeric(15) + DateTime.now().millisecondsSinceEpoch.toString() + p.extension(newProfileImagePath))
            : null,
        "cover_image": newCoverImagePath != null
            ? await MultipartFile.fromFile(newCoverImagePath,
                filename: randomAlphaNumeric(15) + DateTime.now().millisecondsSinceEpoch.toString() + p.extension(newCoverImagePath))
            : null,
      });

      Response response = await Dio().post("$API_HOST/social/profile/update",
          data: formData, options: Options(contentType: 'multipart/form-data'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          if (jsonResponse['result']) {
            sharedPrefs.profilePicUrl = jsonResponse['profileUrl'];
            sharedPrefs.coverPicUrl = jsonResponse['coverUrl'];
          }

          return jsonResponse['result'];
        } else
          throw UpdateProfileException(Error.UNKNOWN_ERROR);
      } else
        throw UpdateProfileException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is UpdateProfileException)
        throw UpdateProfileException(e.error);
      else
        throw UpdateProfileException(Error.NETWORK_ERROR);
    }
  }

  Future<bool> changeUserPassword(
      String userId, String oldPassword, String newPassword) async {
    try {
      Response response = await Dio()
          .post("$API_HOST/social/profile/password/change", data: {
        "userId": userId,
        "oldPassword": oldPassword,
        "newPassword": newPassword
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          return jsonResponse['is_success'];
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else
        throw SocialException(Error.NETWORK_ERROR);
    }
  }

  Future<APIResult> getUserFollowing(int page, String userID) async {
    List<SocialPerson> socialPeople = [];

    try {
      Response response =
          await Dio().get("$API_HOST/social/users/following/$userID/$page");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['social_people']) {
            SocialPerson socialPerson = SocialPerson.fromJson(i);
            socialPeople.add(socialPerson);
          }

          return APIResult(socialPeople, hasReachedMax);
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else
        throw SocialException(Error.NETWORK_ERROR);
    }
  }

  Future<APIResult> searchUserFollowing(
      int page, String userID, String searchTerm) async {
    List<SocialPerson> socialPeople = [];

    try {
      Response response = await Dio().post(
          "$API_HOST/social/users/following/search",
          data: {"search_term": searchTerm});
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['social_people']) {
            SocialPerson socialPerson = SocialPerson.fromJson(i);
            socialPeople.add(socialPerson);
          }

          return APIResult(socialPeople, hasReachedMax);
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else
        throw SocialException(Error.NETWORK_ERROR);
    }
  }
}

class UpdateProfileException implements Exception {
  final Error error;
  UpdateProfileException(this.error);
}

class SocialException implements Exception {
  final Error error;
  SocialException(this.error);
}
