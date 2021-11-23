import 'package:bloc/bloc.dart';
import 'package:groovenation_flutter/cubit/state/change_password_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this.socialRepository)
      : super(ChangePasswordInitialState());

  final SocialRepository socialRepository;

  void changePassword(String oldPassword, String newPassword) async {
    emit(ChangePasswordLoadingState());
    try {
      await socialRepository.changeUserPassword(
          sharedPrefs.userId, oldPassword, newPassword);
      emit(ChangePasswordSuccessState());
    } on SocialException catch (e) {
      emit(ChangePasswordErrorState(e.error));
    }
  }
}
