import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:groovenation_flutter/cubit/state/auth_state.dart';
import 'package:groovenation_flutter/data/repo/auth_repository.dart';
import 'package:groovenation_flutter/models/auth_user.dart';
import 'package:groovenation_flutter/models/conversation.dart';
import 'package:groovenation_flutter/models/message.dart';
import 'package:groovenation_flutter/models/saved_message.dart';
import 'package:groovenation_flutter/models/send_media_task.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepository) : super(AuthInitialState());

  final AuthRepository authRepository;

  void login(String email, String password) async {
    emit(AuthLoginLoadingState());
    try {
      AuthUser authUser = await authRepository.loginUser(email, password);

      sharedPrefs.userId = authUser.userId;
      sharedPrefs.email = email;
      sharedPrefs.profilePicUrl = authUser.profilePicUrl;
      sharedPrefs.coverPicUrl = authUser.coverPicUrl;

      if (authUser.username != null) sharedPrefs.username = authUser.username;
      if (authUser.userCity != null) sharedPrefs.userCity = authUser.userCity;

      emit(AuthLoginSuccessState());
    } on AuthLoginException catch (e) {
      print(e.errorType);
      emit(AuthLoginErrorState(e.errorType));
    }
  }

  void loginFacebook(String email, String name, String facebookId) async {
    emit(AuthLoginLoadingState());
    try {
      AuthUser authUser =
          await authRepository.loginFacebook(email, name, facebookId);
      sharedPrefs.userId = authUser.userId;
      sharedPrefs.email = email;
      sharedPrefs.profilePicUrl = authUser.profilePicUrl;

      sharedPrefs.coverPicUrl = authUser.coverPicUrl;
      if (authUser.username != null) sharedPrefs.username = authUser.username;
      if (authUser.userCity != null) sharedPrefs.userCity = authUser.userCity;

      emit(AuthLoginSuccessState());
    } on AuthLoginException catch (e) {
      emit(AuthLoginErrorState(e.errorType));
    }
  }

  void createUsername(String username) async {
    emit(AuthCreateUsernameLoadingState());
    try {
      bool isSuccess = await authRepository.createUsername(username);
      if (isSuccess) sharedPrefs.username = username;

      emit(AuthCreateUsernameSuccessState());
    } on AuthSignUpException catch (e) {
      emit(AuthCreateUsernameErrorState(e.errorType));
    }
  }

  void loginGoogle(String email, String name, String googleId) async {
    emit(AuthLoginLoadingState());
    try {
      AuthUser authUser =
          await authRepository.loginGoogle(email, name, googleId);
      sharedPrefs.userId = authUser.userId;
      sharedPrefs.email = email;
      sharedPrefs.profilePicUrl = authUser.profilePicUrl;
      sharedPrefs.coverPicUrl = authUser.coverPicUrl;

      if (authUser.username != null) sharedPrefs.username = authUser.username;
      if (authUser.userCity != null) sharedPrefs.userCity = authUser.userCity;

      emit(AuthLoginSuccessState());
    } on AuthLoginException catch (e) {
      print(e);
      emit(AuthLoginErrorState(e.errorType));
    }
  }

  void signup(String email, String firstName, String lastName, String username,
      String password, DateTime dateOfBirth) async {
    emit(AuthSignupLoadingState());
    try {
      AuthUser authUser = await authRepository.signup(
          email, firstName, lastName, username, password, dateOfBirth);
      sharedPrefs.userId = authUser.userId;
      sharedPrefs.email = email;
      sharedPrefs.profilePicUrl = authUser.profilePicUrl;
      sharedPrefs.coverPicUrl = authUser.coverPicUrl;

      if (authUser.username != null) sharedPrefs.username = authUser.username;
      if (authUser.userCity != null) sharedPrefs.userCity = authUser.userCity;

      emit(AuthSignupSuccessState());
    } on AuthSignUpException catch (e) {
      print(e);
      emit(AuthSignupErrorState(e.errorType));
    }
  }

  void checkUsernameExists(String username) async {
    emit(AuthUsernameCheckLoadingState());
    try {
      bool exists = await authRepository.checkUsernameExists(username);
      emit(AuthUsernameCheckCompleteState(exists
          ? UsernameInputStatus.USERNAME_UNAVAILABLE
          : UsernameInputStatus.USERNAME_AVAILABLE));
    } catch (e) {
      emit(AuthUsernameCheckCompleteState(UsernameInputStatus.NONE));
    }
  }

  void logout() {
    sharedPrefs.userId = null;
    sharedPrefs.email = null;
    sharedPrefs.profilePicUrl = null;
    sharedPrefs.coverPicUrl = null;
    sharedPrefs.username = null;
    sharedPrefs.userCity = null;
    sharedPrefs.isUserMessagesLoaded = null;

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.deleteToken();

    FlutterUploader uploader = FlutterUploader();
    uploader.cancelAll();

    Hive.openBox<Conversation>('conversation').then((value) => value.clear());
    Hive.openBox<SavedMessage>('savedmessage').then((value) => value.clear());
    Hive.openBox<SendMediaTask>('sendmediatask').then((value) => value.clear());
    Hive.openBox<Message>('message').then((value) => value.clear());
  }
}
