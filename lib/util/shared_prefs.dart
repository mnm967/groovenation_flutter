import 'package:groovenation_flutter/constants/settings_strings.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences mSharedPrefs;

  init() async {
    if (mSharedPrefs == null) {
      mSharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String get userId => mSharedPrefs.getString(PREF_USER_ID_KEY) ?? null;

  set userId(String value) {
    mSharedPrefs.setString(PREF_USER_ID_KEY, value);
  }
  
  String get username => mSharedPrefs.getString(PREF_USERNAME_KEY) ?? null;

  set username(String value) {
    mSharedPrefs.setString(PREF_USERNAME_KEY, value);
  }
  
  String get email => mSharedPrefs.getString(PREF_EMAIL_KEY) ?? null;

  set email(String value) {
    mSharedPrefs.setString(PREF_EMAIL_KEY, value);
  }
  
  String get profilePicUrl => mSharedPrefs.getString(PREF_PROFILE_PIC_KEY) ?? "";

  set profilePicUrl(String value) {
    mSharedPrefs.setString(PREF_PROFILE_PIC_KEY, value);
  }
  
  String get coverPicUrl => mSharedPrefs.getString(PREF_COVER_PIC_KEY) ?? "";

  set coverPicUrl(String value) {
    mSharedPrefs.setString(PREF_COVER_PIC_KEY, value);
  }
  
  String get userCity => mSharedPrefs.getString(PREF_CITY_KEY) ?? null;

  set userCity(String value) {
    mSharedPrefs.setString(PREF_CITY_KEY, value);
  }
  
  String get chatNotificationSetting => mSharedPrefs.getString(PREF_CHAT_NOTIFICATION_SETTING_KEY) ?? CHAT_NOTIFICATION_ON;

  set chatNotificationSetting(String value) {
    mSharedPrefs.setString(PREF_CHAT_NOTIFICATION_SETTING_KEY, value);
  }
  
  String get notificationSetting => mSharedPrefs.getString(PREF_NOTIFICATION_SETTING_KEY) ?? NOTIFICATION_FAVOURITE_ONLY;

  set notificationSetting(String value) {
    mSharedPrefs.setString(PREF_NOTIFICATION_SETTING_KEY, value);
  }
}

final sharedPrefs = SharedPrefs();