import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/user/profile_settings_cubit.dart';
import 'package:groovenation_flutter/cubit/state/profile_settings_state.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String? newProfileImagePath;
  String? newCoverImagePath;
  final emailTextController =
      TextEditingController(text: "${sharedPrefs.email}");

  final picker = ImagePicker();

  Future<void> _chooseProfileImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File? croppedFile =
        await _cropImage(pickedFile.path, CropAspectRatioPreset.square);

    setState(() {
      newProfileImagePath = croppedFile!.path;
    });
  }

  Future<void> _chooseCoverImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File? croppedFile =
        await _cropImage(pickedFile.path, CropAspectRatioPreset.ratio16x9);

    setState(() {
      newCoverImagePath = croppedFile!.path;
    });
  }

  Future<File?> _cropImage(
      String imagePath, CropAspectRatioPreset ratio) async {
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [ratio],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
  }

  final GlobalKey<State> _loadingDialogKey = new GlobalKey<State>();
  bool _isLoadingVisible = false;
  Future<void> _showLoadingDialog(BuildContext context) async {
    _isLoadingVisible = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(_loadingDialogKey, "Please Wait...");
        });
  }

  void _hideLoadingDialog() {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      Navigator.of(_loadingDialogKey.currentContext!, rootNavigator: true)
          .pop();
    }
  }

  Future<File?> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
    );

    return result;
  }

  void _saveProfileChanges() async {
    _showLoadingDialog(context);

    File? profileFile =
        newProfileImagePath != null ? File(newProfileImagePath!) : null;
    File? coverFile =
        newCoverImagePath != null ? File(newCoverImagePath!) : null;

    if (profileFile != null) {
      if (profileFile.lengthSync() > 500000) {
        newProfileImagePath = (await _compressAndGetFile(profileFile,
                "${profileFile.parent.path}/compressed-${profileFile.path.split('/').last}"))!
            .path;
      }
    }

    if (coverFile != null) {
      if (coverFile.lengthSync() > 500000) {
        newCoverImagePath = (await _compressAndGetFile(coverFile,
                "${coverFile.parent.path}/compressed-${coverFile.path.split('/').last}"))!
            .path;
      }
    }

    final ProfileSettingsCubit profileSettingsCubit =
        BlocProvider.of<ProfileSettingsCubit>(context);

    profileSettingsCubit.updateProfileSettings(context,
        emailTextController.text, newProfileImagePath, newCoverImagePath);
  }

  void _blocListener(context, state) {
    if (state is ProfileSettingsSuccessState) {
      _hideLoadingDialog();
      Navigator.pop(context);
    } else if (state is ProfileSettingsErrorState) {
      _hideLoadingDialog();
      switch (state.error) {
        case AppError.IMAGE_SIZE_ERROR:
          alertUtil.sendAlert(BASIC_ERROR_TITLE, IMAGE_SIZE_ERROR_PROMPT,
              Colors.red, Icons.error);
          break;
        case AppError.NETWORK_ERROR:
          alertUtil.sendAlert(
              BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT, Colors.red, Icons.error);
          break;
        default:
          alertUtil.sendAlert(
              BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT, Colors.red, Icons.error);
          break;
      }

      final ProfileSettingsCubit profileSettingsCubit =
          BlocProvider.of<ProfileSettingsCubit>(context);
      profileSettingsCubit.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return BlocListener<ProfileSettingsCubit, ProfileSettingsState>(
      listener: _blocListener,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title(),
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 56, bottom: 8),
                      children: [
                        _profileImage(),
                        _usernameInput(),
                        _emailInput(),
                        _coverImage(),
                        _changePasswordButton(),
                        _saveChangesButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveChangesButton() {
    return Padding(
      padding: EdgeInsets.only(top: 24, bottom: 24),
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: TextButton(
          onPressed: () => _saveProfileChanges(),
          child: Container(
            height: 64,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Save Changes",
                style: TextStyle(
                    fontFamily: 'Lato', color: Colors.deepPurple, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _changePasswordButton() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/change_password_settings');
          },
          child: Container(
            height: 64,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Change Password",
                style: TextStyle(
                    fontFamily: 'Lato', color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileImage() {
    return Align(
      child: TextButton(
        onPressed: () => _chooseProfileImage(),
        child: SizedBox(
          height: 116,
          width: 116,
          child: CircleAvatar(
            backgroundImage: (newProfileImagePath == null
                    ? CachedNetworkImageProvider("${sharedPrefs.profilePicUrl}")
                    : FileImage(new File(newProfileImagePath!)))
                as ImageProvider<Object>?,
            child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.penAlt,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _usernameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 56),
      child: TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'Lato',
        ),
        readOnly: true,
        initialValue: "${sharedPrefs.username}",
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          labelText: "Public Username",
          labelStyle: TextStyle(fontFamily: 'Lato', color: Colors.white),
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
              borderSide: const BorderSide(color: Colors.white, width: 1.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _emailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'Lato',
        ),
        controller: emailTextController,
        //initialValue: "${sharedPrefs.email}",
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          labelText: "Email Address",
          labelStyle: TextStyle(fontFamily: 'Lato', color: Colors.white),
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
              borderSide: const BorderSide(color: Colors.white, width: 1.0)),
          focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
              borderSide:
                  const BorderSide(color: Color(0xffE65AB9), width: 1.0)),
        ),
      ),
    );
  }

  Widget _coverImage() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: AspectRatio(
          aspectRatio: 1 / 0.8,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      (newCoverImagePath == null
                              ? CachedNetworkImageProvider(
                                  "${sharedPrefs.coverPicUrl}")
                              : FileImage(new File(newCoverImagePath!)))
                          as ImageProvider<Object>,
                  fit: BoxFit.cover),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: RawMaterialButton(
                      onPressed: () => _chooseCoverImage(),
                      constraints:
                          BoxConstraints.expand(width: 108, height: 108),
                      elevation: 0,
                      child: Center(
                        child: Icon(
                          FontAwesomeIcons.penAlt,
                          color: Colors.white,
                          size: 32.0,
                        ),
                      ),
                      shape: CircleBorder(
                          side: BorderSide(width: 1, color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: Text(
                      "Change Cover Image",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato',
                          fontSize: 36),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, top: 8),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(900)),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(left: 8),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24, top: 8),
          child: Text(
            "Profile",
            style: TextStyle(
                color: Colors.white, fontSize: 36, fontFamily: 'LatoBold'),
          ),
        ),
      ],
    );
  }
}
