import 'package:crypt/crypt.dart';
import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/auth_user.dart';
import 'package:groovenation_flutter/models/city.dart';
import 'package:groovenation_flutter/util/network_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class AuthRepository {
  Future<AuthUser?> loginUser(String email, String password) async {
    final c1 = Crypt.sha256(password, rounds: 10000, salt: PASSWORD_SHA_SALT);

    Map<String, String> json = {
      "email": email,
      "password": c1.hash,
    };

    return authenticateUserLogin("$API_HOST/users/login/email", json);
  }

  Future<AuthUser?> loginFacebook(
      String? email, String? name, String? facebookId) async {
    Map<String, String?> json = {
      "email": email,
      "name": name,
      "facebookId": facebookId,
    };

    return authenticateUserLogin("$API_HOST/users/login/facebook", json);
  }

  Future<AuthUser?> loginGoogle(
      String email, String? name, String googleId) async {
    Map<String, String?> json = {
      "email": email,
      "name": name,
      "googleId": googleId,
    };

    return authenticateUserLogin("$API_HOST/users/login/google", json);
  }

  Future<AuthUser?> signup(String email, String firstName, String lastName,
      String username, String password, DateTime dateOfBirth) async {
    final c1 = Crypt.sha256(password, rounds: 10000, salt: PASSWORD_SHA_SALT);

    Map<String, dynamic> json = {
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "password": c1.hash,
      "dateOfBirth": dateOfBirth.millisecondsSinceEpoch,
    };

    return authenticateUserSignup("$API_HOST/users/create/email", json);
  }

  CancelToken? _checkCancelToken;
  Future<bool?> checkUsernameExists(String username) async {
    NetworkUtil.cancel(_checkCancelToken);

    _checkCancelToken = null;
    _checkCancelToken = CancelToken();

    String url = "$API_HOST/users/check/username";
    var body = {
      "username": username,
    };

    var jsonResponse = await NetworkUtil.executePostRequest(
        url, body, _onRequestError, _checkCancelToken);

    if (jsonResponse != null) {
      return jsonResponse['username_exists'];
    }

    return false;
  }

  Future<AuthUser?> authenticateUserLogin(
      String url, Map<String, String?> body) async {
    var jsonResponse =
        await NetworkUtil.executePostRequest(url, body, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['result'] == LOGIN_FAILED)
        throw AuthException(AuthError.LOGIN_FAILED);
      else
        return AuthUser.fromJson(jsonResponse['result']);
    }

    return null;
  }

  Future<AuthUser?> authenticateUserSignup(
      String url, Map<String, dynamic> body) async {
    var jsonResponse =
        await NetworkUtil.executePostRequest(url, body, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['result'] == EMAIL_EXISTS)
        throw AuthException(AuthError.EMAIL_EXISTS_ERROR);
      else if (jsonResponse['result'] == USERNAME_EXISTS)
        throw AuthException(AuthError.USERNAME_EXISTS_ERROR);
      else
        return AuthUser.fromJson(jsonResponse['result']);
    }

    return null;
  }

  Future<bool?> createUsername(String username) async {
    String url = "$API_HOST/users/create/username";
    var body = {'userId': sharedPrefs.userId, 'username': username};

    var jsonResponse =
        await NetworkUtil.executePostRequest(url, body, _onRequestError);

    if (jsonResponse != null) {
      if (jsonResponse['result'] == USERNAME_EXISTS)
        throw AuthException(AuthError.USERNAME_EXISTS_ERROR);
      else
        return jsonResponse['result'];
    }

    return null;
  }

  Future<List<City>?> getAvailableCities() async {
    List<City> cities = [];

    var jsonResponse = await NetworkUtil.executeGetRequest(
        "$API_HOST/users/cities/available", _onRequestError);

    if (jsonResponse != null) {
      for (Map i in jsonResponse['cities']) {
        City city = City.fromJson(i);
        cities.add(city);
      }

      return cities;
    }

    return null;
  }

  _onRequestError(e) {
    if (e is AuthException)
      throw AuthException(e.error);
    else if (e is DioError) if (e.type != DioErrorType.cancel)
      throw AuthException(AuthError.NETWORK_ERROR);
    else
      throw AuthException(AuthError.UNKNOWN_ERROR);
  }
}

class AuthException implements Exception {
  final AuthError error;
  AuthException(this.error);
}
