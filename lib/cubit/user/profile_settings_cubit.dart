import 'package:flutter/material.dart';
import 'package:groovenation_flutter/cubit/state/profile_settings_state.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/util/bloc_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ProfileSettingsCubit extends Cubit<ProfileSettingsState> {
  ProfileSettingsCubit(this.socialRepository)
      : super(ProfileSettingsInitialState());

  final SocialRepository socialRepository;

  void updateProfileSettings(BuildContext context, String email,
      String? newProfileImagePath, String? newCoverImagePath) async {
    try {
      emit(ProfileSettingsLoadingState());
      await socialRepository.updateProfileSettings(
          sharedPrefs.userId, email, newProfileImagePath, newCoverImagePath);

      BlocUtil.updateSocialPerson(
        context,
        SocialPerson(sharedPrefs.userId, sharedPrefs.username,
            sharedPrefs.profilePicUrl, sharedPrefs.coverPicUrl, false, false, sharedPrefs.userFollowersCount),
      );

      emit(ProfileSettingsSuccessState());
    } on SocialException catch (e) {
      emit(ProfileSettingsErrorState(e.error));
    }
  }

  void reset() {
    emit(ProfileSettingsInitialState());
  }
}
