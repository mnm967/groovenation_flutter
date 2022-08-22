import 'package:dio/dio.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class NetworkUtil {
  static const TIMEOUT_SEC = 5;
  static Future<dynamic> executePostRequest(
      String url, var body, Function onError,
      [CancelToken? cancelToken, Options? options]) async {
    try {
      if (options != null) {
        if (sharedPrefs.authToken != null)
          options.headers!['authorization'] = "Bearer ${sharedPrefs.authToken}";
        options.sendTimeout = TIMEOUT_SEC * 1000;
        options.receiveTimeout = TIMEOUT_SEC * 1000;
      }

      Response response = await Dio().post(
        url,
        data: body,
        options: options == null
            ? Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: sharedPrefs.authToken != null
                    ? {"authorization": "Bearer ${sharedPrefs.authToken}"}
                    : {},
                sendTimeout: TIMEOUT_SEC * 1000,
                receiveTimeout: TIMEOUT_SEC * 1000)
            : options,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        if (response.data['status'] != -1) {
          return response.data;
        } else {
          onError(APIException());
        }
      }
    } catch (e) {
      print(e);
      if (!(e is DioError))
        onError(e);
      else {
        if (e.error != DioErrorType.cancel) onError(e);
      }
    }

    return null;
  }

  static Future<dynamic> executeGetRequest(String url, Function onError,
      [CancelToken? cancelToken]) async {
    try {
      Response response = await Dio().get(
        url,
        options: Options(
            headers: sharedPrefs.authToken != null
                ? {"authorization": "Bearer ${sharedPrefs.authToken}"}
                : {},
            sendTimeout: TIMEOUT_SEC * 1000,
            receiveTimeout: TIMEOUT_SEC * 1000),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == 1) {
          return response.data;
        } else {
          onError(APIException());
        }
      }
    } catch (e) {
      if (!(e is DioError))
        onError(e);
      else {
        if (e.error != DioErrorType.cancel) onError(e);
      }
    }

    return null;
  }

  static void cancel(CancelToken? cancelToken) {
    if (cancelToken != null) {
      try {
        cancelToken.cancel();
      } catch (_) {}
    }
  }
}

class APIException implements Exception {}
