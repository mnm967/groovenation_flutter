import 'dart:io';

import 'package:crypt/crypt.dart';
import 'package:dio/dio.dart';
import 'package:groovenation_flutter/constants/auth_error_types.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/models/auth_user.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class AuthRepository {
  Future<AuthUser> loginUser(String email, String password) async {
    final c1 = Crypt.sha256(password, rounds: 10000, salt: PASSWORD_SHA_SALT);

    Map<String, String> json = {
      "email": email,
      "password": c1.hash,
    };

    return authenticateUserLogin("$API_HOST/users/login/email", json);
  }

  Future<AuthUser> loginFacebook(
      String email, String name, String facebookId) async {
    Map<String, String> json = {
      "email": email,
      "name": name,
      "facebookId": facebookId,
    };

    return authenticateUserLogin("$API_HOST/users/login/facebook", json);
  }

  Future<AuthUser> loginGoogle(
      String email, String name, String googleId) async {
    Map<String, String> json = {
      "email": email,
      "name": name,
      "googleId": googleId,
    };

    return authenticateUserLogin("$API_HOST/users/login/google", json);
  }

  Future<AuthUser> signup(String email, String firstName, String lastName,
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

  CancelToken _checkCancelToken;
  Future<bool> checkUsernameExists(String username) async {
    if (_checkCancelToken != null) {
      try {
        _checkCancelToken.cancel();
        _checkCancelToken = null;
      } catch (e) {}
    }

    _checkCancelToken = CancelToken();

    try {
      Response response = await Dio().post("$API_HOST/users/check/username",
          data: {
            "username": username,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
          cancelToken: _checkCancelToken);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          print("uname - " +
              username +
              " - " +
              jsonResponse['username_exists'].toString());
          return jsonResponse['username_exists'];
        } else
          throw AuthException(Error.UNKNOWN_ERROR);
      } else
        throw AuthException(Error.UNKNOWN_ERROR);
    } catch (e) {
      if (e is AuthException)
        throw AuthException(e.error);
      else {
        if (e is DioError) 
        if (e.type == DioErrorType.CANCEL) {
        } else
          throw AuthException(Error.NETWORK_ERROR);
        else
          throw AuthException(Error.NETWORK_ERROR);
      }
    }
  }

  Future<AuthUser> authenticateUserLogin(
      String url, Map<String, String> body) async {
    try {
      Response response = await Dio().post(url,
          data: body,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      print("Resp:" + response.data.toString());

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          if (jsonResponse['result'] == LOGIN_FAILED)
            throw AuthLoginException(AuthLoginErrorType.LOGIN_FAILED);
          else
            return AuthUser.fromJson(jsonResponse['result']);
        } else
          throw AuthLoginException(AuthLoginErrorType.UNKNOWN_ERROR);
      } else
        throw AuthLoginException(AuthLoginErrorType.UNKNOWN_ERROR);
    } catch (e) {
      print(e);
      if (e is AuthLoginException)
        throw AuthLoginException(e.errorType);
      else
        throw AuthLoginException(AuthLoginErrorType.UNKNOWN_ERROR);
    }
  }

  Future<AuthUser> authenticateUserSignup(
      String url, Map<String, dynamic> body) async {
    try {
      Response response = await Dio().post(url,
          data: body,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          if (jsonResponse['result'] == EMAIL_EXISTS)
            throw AuthSignUpException(AuthSignUpErrorType.EMAIL_EXISTS_ERROR);
          else if (jsonResponse['result'] == USERNAME_EXISTS)
            throw AuthSignUpException(
                AuthSignUpErrorType.USERNAME_EXISTS_ERROR);
          else
            return AuthUser.fromJson(jsonResponse['result']);
        } else
          throw AuthSignUpException(AuthSignUpErrorType.UNKNOWN_ERROR);
      } else
        throw AuthSignUpException(AuthSignUpErrorType.UNKNOWN_ERROR);
    } catch (e) {
      if (e is AuthSignUpException)
        throw AuthSignUpException(e.errorType);
      else
        throw AuthSignUpException(AuthSignUpErrorType.UNKNOWN_ERROR);
    }
  }

  Future<bool> createUsername(String username) async {
    try {
      Response response = await Dio().post("$API_HOST/users/create/username",
          data: {'userId': sharedPrefs.userId, 'username': username},
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse['status'] == 1) {
          if (jsonResponse['result'] == USERNAME_EXISTS)
            throw AuthSignUpException(
                AuthSignUpErrorType.USERNAME_EXISTS_ERROR);
          else
            return jsonResponse['result'];
        } else
          throw AuthSignUpException(AuthSignUpErrorType.UNKNOWN_ERROR);
      } else
        throw AuthSignUpException(AuthSignUpErrorType.UNKNOWN_ERROR);
    } catch (e) {
      if (e is AuthSignUpException)
        throw AuthSignUpException(e.errorType);
      else
        throw AuthSignUpException(AuthSignUpErrorType.UNKNOWN_ERROR);
    }
  }
}

class AuthSignUpException implements Exception {
  final AuthSignUpErrorType errorType;
  AuthSignUpException(this.errorType);
}

class AuthLoginException implements Exception {
  final AuthLoginErrorType errorType;
  AuthLoginException(this.errorType);
}

class AuthException implements Exception {
  final Error error;
  AuthException(this.error);
}
