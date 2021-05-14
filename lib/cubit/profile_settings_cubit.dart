import 'package:groovenation_flutter/cubit/state/profile_settings_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  ProfileSettingsCubit(this.socialRepository)
      : super(ProfileSettingsInitialState());

  final SocialRepository socialRepository;

  void updateProfileSettings(String email, String newProfileImagePath,
      String newCoverImagePath) async {
    try {
      emit(ProfileSettingsLoadingState());
      await socialRepository.updateProfileSettings(
          sharedPrefs.userId, email, newProfileImagePath, newCoverImagePath);
      emit(ProfileSettingsSuccessState());
    } on UpdateProfileException catch (e) {
      emit(ProfileSettingsErrorState(e.error));
    }
  }

  void reset() {
    emit(ProfileSettingsInitialState());
  }
}
