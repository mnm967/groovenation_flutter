import 'package:crypt/crypt.dart';
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
    print(page);
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
          await Dio().get("$API_HOST/social/post/comments/$uid/$postID/$page");
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

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

  Future<SocialPost> uploadSocialPost(
      String mediaFilePath, String caption, String clubId, bool isVideo) async {
    var uid = sharedPrefs.userId;

    try {
      FormData formData = new FormData.fromMap({
        "user_id": uid,
        "caption": caption,
        "club_id": clubId,
        "social_file": await MultipartFile.fromFile(mediaFilePath,
            filename: randomAlphaNumeric(15) +
                DateTime.now().millisecondsSinceEpoch.toString() +
                p.extension(mediaFilePath)),
      });

      Response response = await Dio().post("$API_HOST/social/post/create",
          data: formData, options: Options(contentType: 'multipart/form-data'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data.toString());

        if (jsonResponse['status'] == 1) {
          if (jsonResponse['social_post'] != null) {
            SocialPost post = SocialPost.fromJson(jsonResponse['social_post']);
            return post;
          }

          return null;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is SocialException)
        throw SocialException(e.error);
      else
        throw SocialException(Error.NETWORK_ERROR);
    }
  }

  CancelToken _searchCancelToken;
  Future<APIResult> searchUsers(String searchTerm, int page) async {
    List<SocialPerson> people = [];

    if (_searchCancelToken != null) {
      try {
        _searchCancelToken.cancel();
        _searchCancelToken = null;
      } catch (e) {}
    }

    _searchCancelToken = CancelToken();

    try {
      Response response = await Dio().post("$API_HOST/social/search/users",
          data: {
            'search_term': searchTerm,
            'page': page,
            'user_id': sharedPrefs.userId,
          },
          cancelToken: _searchCancelToken);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response.data);

        if (jsonResponse['status'] == 1) {
          bool hasReachedMax = jsonResponse['has_reached_max'];

          for (Map i in jsonResponse['social_people']) {
            SocialPerson person = SocialPerson.fromJson(i);
            people.add(person);
          }

          return APIResult(people, hasReachedMax);
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
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
    final c1 =
        Crypt.sha256(oldPassword, rounds: 10000, salt: PASSWORD_SHA_SALT);
    final c2 =
        Crypt.sha256(newPassword, rounds: 10000, salt: PASSWORD_SHA_SALT);

    try {
      Response response =
          await Dio().post("$API_HOST/social/profile/password/change",
              data: {
                "userId": userId,
                "oldPassword": c1.hash,
                "newPassword": c2.hash,
              },
              options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          return jsonResponse['is_success'];
        } else if (jsonResponse['status'] == -2) {
          throw SocialException(Error.INCORRECT_OLD_PASSWORD);
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
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<bool> changeLikeSocialPost(SocialPost post) async {
    var uid = sharedPrefs.userId;

    try {
      Response response = await Dio().post(
          post.hasUserLiked
              ? "$API_HOST/social/post/like"
              : "$API_HOST/social/post/unlike",
          data: {
            "user_id": uid,
            "post_id": post.postID,
          });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

        if (jsonResponse['status'] == 1) {
          return true;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<bool> changeUserFollowing(SocialPerson person) async {
    var uid = sharedPrefs.userId;

    try {
      Response response = await Dio().get(person.isUserFollowing
          ? "$API_HOST/social/follow/${person.personID}/$uid"
          : "$API_HOST/social/unfollow/${person.personID}/$uid");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

        if (jsonResponse['status'] == 1) {
          return true;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<bool> changeLikeComment(SocialComment comment) async {
    var uid = sharedPrefs.userId;

    try {
      Response response = await Dio().post(
          comment.hasUserLiked
              ? "$API_HOST/social/post/comment/like"
              : "$API_HOST/social/post/comment/unlike",
          data: {
            "user_id": uid,
            "comment_id": comment.commentId,
          });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

        if (jsonResponse['status'] == 1) {
          return true;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<bool> addSocialComment(String postId, String comment) async {
    var uid = sharedPrefs.userId;

    try {
      Response response =
          await Dio().post("$API_HOST/social/post/comment/add", data: {
        "user_id": uid,
        "post_id": postId,
        "comment": comment,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

        if (jsonResponse['status'] == 1) {
          return true;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<bool> sendReport(String reportType, String comment, SocialPost post,
      SocialPerson person) async {
    try {
      Response response = await Dio().post("$API_HOST/social/report", data: {
        "report_type": reportType,
        "report_comment": comment,
        "report_user": person != null ? person.personID : null,
        "report_post": post != null ? post.postID : null,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

        if (jsonResponse['status'] == 1) {
          return true;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else {
          print(e);
          throw SocialException(Error.NETWORK_ERROR);
        }
      }
    }
  }

  Future<bool> changeUserBlock(String personId, bool isBlocked) async {
    var uid = sharedPrefs.userId;

    try {
      Response response = isBlocked
          ? await Dio().get("$API_HOST/social/block/$uid/$personId")
          : await Dio().get("$API_HOST/social/unblock/$uid/$personId");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        print(response);

        if (jsonResponse['status'] == 1) {
          return true;
        } else
          throw SocialException(Error.UNKNOWN_ERROR);
      } else
        throw SocialException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is SocialException)
        throw SocialException(e.error);
      else {
        if (e is DioError) if (e.type == DioErrorType.cancel) {
          throw e;
        } else
          throw SocialException(Error.NETWORK_ERROR);
        else
          throw SocialException(Error.NETWORK_ERROR);
      }
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
