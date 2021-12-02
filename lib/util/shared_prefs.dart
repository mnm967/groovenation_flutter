import 'package:groovenation_flutter/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? mSharedPrefs;

  init() async {
    if (mSharedPrefs == null) {
      mSharedPrefs = await SharedPreferences.getInstance();
    }
  }

  double? get defaultLat => mSharedPrefs!.getDouble(PREF_DEFAULT_CITY_LAT_KEY) ?? null;

  set defaultLat(double? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_DEFAULT_CITY_LAT_KEY);
    else
      mSharedPrefs!.setDouble(PREF_DEFAULT_CITY_LAT_KEY, value);
  }
  
  double? get defaultLon => mSharedPrefs!.getDouble(PREF_DEFAULT_CITY_LON_KEY) ?? null;

  set defaultLon(double? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_DEFAULT_CITY_LON_KEY);
    else
      mSharedPrefs!.setDouble(PREF_DEFAULT_CITY_LON_KEY, value);
  }
  
  String? get authToken => mSharedPrefs!.getString(PREF_AUTH_TOKEN_KEY) ?? null;

  set authToken(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_AUTH_TOKEN_KEY);
    else
      mSharedPrefs!.setString(PREF_AUTH_TOKEN_KEY, value);
  }
  
  String? get userId => mSharedPrefs!.getString(PREF_USER_ID_KEY) ?? null;

  set userId(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_USER_ID_KEY);
    else
      mSharedPrefs!.setString(PREF_USER_ID_KEY, value);
  }

  String? get username => mSharedPrefs!.getString(PREF_USERNAME_KEY) ?? null;

  set username(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_USERNAME_KEY);
    else
      mSharedPrefs!.setString(PREF_USERNAME_KEY, value);
  }

  String? get email => mSharedPrefs!.getString(PREF_EMAIL_KEY) ?? null;

  set email(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_EMAIL_KEY);
    else
      mSharedPrefs!.setString(PREF_EMAIL_KEY, value);
  }

  String get profilePicUrl =>
      mSharedPrefs!.getString(PREF_PROFILE_PIC_KEY) ?? "";

  set profilePicUrl(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_PROFILE_PIC_KEY);
    else
      mSharedPrefs!.setString(PREF_PROFILE_PIC_KEY, value);
  }

  String get coverPicUrl => mSharedPrefs!.getString(PREF_COVER_PIC_KEY) ?? "";

  set coverPicUrl(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_COVER_PIC_KEY);
    else
      mSharedPrefs!.setString(PREF_COVER_PIC_KEY, value);
  }

  String? get userCity => mSharedPrefs!.getString(PREF_CITY_KEY) ?? null;

  set userCity(String? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_CITY_KEY);
    else
      mSharedPrefs!.setString(PREF_CITY_KEY, value);
  }

  String get chatNotificationSetting =>
      mSharedPrefs!.getString(PREF_CHAT_NOTIFICATION_SETTING_KEY) ??
      CHAT_NOTIFICATION_ON;

  set chatNotificationSetting(String value) {
    mSharedPrefs!.setString(PREF_CHAT_NOTIFICATION_SETTING_KEY, value);
  }

  String get notificationSetting =>
      mSharedPrefs!.getString(PREF_NOTIFICATION_SETTING_KEY) ??
      NOTIFICATION_ALL_NEARBY;

  set notificationSetting(String value) {
    mSharedPrefs!.setString(PREF_NOTIFICATION_SETTING_KEY, value);
  }
  
  List<String> get favouriteClubIds =>
      mSharedPrefs!.getStringList(PREF_FAVOURITE_CLUBS_IDS_KEY) ??
      [];

  set favouriteClubIds(List<String> value) {
    mSharedPrefs!.setStringList(PREF_FAVOURITE_CLUBS_IDS_KEY, value);
  }
  
  List<String> get mutedConversations =>
      mSharedPrefs!.getStringList(PREF_MUTED_CONVERSATIONS_IDS_KEY) ??
      [];

  set mutedConversations(List<String> value) {
    mSharedPrefs!.setStringList(PREF_MUTED_CONVERSATIONS_IDS_KEY, value);
  }

  bool get deviceTokenSaved =>
      mSharedPrefs!.getBool(PREF_FCM_TOKEN_SAVED_KEY) ?? false;

  set deviceTokenSaved(bool value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_FCM_TOKEN_SAVED_KEY);
    else
      mSharedPrefs!.setBool(PREF_FCM_TOKEN_SAVED_KEY, value);
  }

  bool get isUserMessagesLoaded =>
      mSharedPrefs!.getBool(PREF_USER_MESSAGES_LOADED_KEY) ?? false;

  set isUserMessagesLoaded(bool? value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_USER_MESSAGES_LOADED_KEY);
    else
      mSharedPrefs!.setBool(PREF_USER_MESSAGES_LOADED_KEY, value);

    if (onUserMessagesValueChanged != null) onUserMessagesValueChanged!();
  }
 
  bool get isUserConversationsLoaded =>
      mSharedPrefs!.getBool(PREF_USER_MESSAGES_LOADED_KEY) ?? false;

  set isUserConversationsLoaded(bool value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_USER_MESSAGES_LOADED_KEY);
    else
      mSharedPrefs!.setBool(PREF_USER_MESSAGES_LOADED_KEY, value);

  }

  bool get isSocialSoundEnabled =>
      mSharedPrefs!.getBool(PREF_SOUND_ENABLED_KEY) ?? false;

  set isSocialSoundEnabled(bool value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_SOUND_ENABLED_KEY);
    else
      mSharedPrefs!.setBool(PREF_SOUND_ENABLED_KEY, value);
  }
  
  int get userFollowersCount =>
      mSharedPrefs!.getInt(PREF_USER_FOLLOWERS_COUNT_KEY) ?? 0;

  set userFollowersCount(int value) {
    if (value == null)
      mSharedPrefs!.remove(PREF_USER_FOLLOWERS_COUNT_KEY);
    else
      mSharedPrefs!.setInt(PREF_USER_FOLLOWERS_COUNT_KEY, value);
  }

  Function? onUserMessagesValueChanged;
}

final sharedPrefs = SharedPrefs();
