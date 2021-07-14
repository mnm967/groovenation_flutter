import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/profile_settings_cubit.dart';
import 'package:groovenation_flutter/cubit/state/profile_settings_state.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String newProfileImagePath;
  String newCoverImagePath;
  final emailTextController =
      TextEditingController(text: "${sharedPrefs.email}");

  final picker = ImagePicker();

  Future<void> _chooseProfileImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ));

    setState(() {
      newProfileImagePath = croppedFile.path;
    });
  }

  Future<void> _chooseCoverImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio16x9,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    setState(() {
      newCoverImagePath = croppedFile.path;
    });
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _isLoadingVisible = false;
  Future<void> _showLoadingDialog(BuildContext context) async {
    _isLoadingVisible = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(_keyLoader, "Please Wait...");
        });
  }

  _hideLoadingDialog() {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }
  }

  _saveProfileChanges() {
    _showLoadingDialog(context);

    final ProfileSettingsCubit profileSettingsCubit =
        BlocProvider.of<ProfileSettingsCubit>(context);

    profileSettingsCubit.updateProfileSettings(
        emailTextController.text, newProfileImagePath, newCoverImagePath);
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return BlocListener<ProfileSettingsCubit, ProfileSettingsState>(
        listener: (context, state) {
          if (state is ProfileSettingsSuccessState) {
            _hideLoadingDialog();
            Navigator.pop(context);
          } else if (state is ProfileSettingsErrorState) {
            _hideLoadingDialog();
            switch (state.error) {
              case Error.IMAGE_SIZE_ERROR:
                alertUtil.sendAlert(BASIC_ERROR_TITLE, IMAGE_SIZE_ERROR_PROMPT,
                    Colors.red, Icons.error);
                break;
              case Error.NETWORK_ERROR:
                alertUtil.sendAlert(BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT,
                    Colors.red, Icons.error);
                break;
              default:
                alertUtil.sendAlert(BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT,
                    Colors.red, Icons.error);
                break;
            }

            final ProfileSettingsCubit profileSettingsCubit =
                BlocProvider.of<ProfileSettingsCubit>(context);
            profileSettingsCubit.reset();
          }
        },
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
                        Row(
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
                                  child: FlatButton(
                                    padding: EdgeInsets.only(left: 8),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(left: 24, top: 8),
                                child: Text(
                                  "Profile",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontFamily: 'LatoBold'),
                                )),
                          ],
                        ),
                        ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 56, bottom: 8),
                          children: [
                            Align(
                              child: FlatButton(
                                onPressed: () => _chooseProfileImage(),
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                    height: 116,
                                    width: 116,
                                    child: CircleAvatar(
                                      backgroundImage: newProfileImagePath ==
                                              null
                                          ? OptimizedCacheImageProvider(
                                              "${sharedPrefs.profilePicUrl}")
                                          : FileImage(
                                              new File(newProfileImagePath)),
                                      child: Container(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
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
                                    )),
                              ),
                            ),
                            Padding(
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
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    labelText: "Public Username",
                                    labelStyle: TextStyle(
                                        fontFamily: 'Lato',
                                        color: Colors.white),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        borderSide: const BorderSide(
                                            color: Colors.white, width: 1.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        borderSide: const BorderSide(
                                            color: Colors.white, width: 1.0)),
                                  )),
                            ),
                            Padding(
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
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    labelText: "Email Address",
                                    labelStyle: TextStyle(
                                        fontFamily: 'Lato',
                                        color: Colors.white),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        borderSide: const BorderSide(
                                            color: Colors.white, width: 1.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                        borderSide: const BorderSide(
                                            color: Color(0xffE65AB9),
                                            width: 1.0)),
                                  )),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0))),
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: AspectRatio(
                                      aspectRatio: 1 / 0.8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: newCoverImagePath == null
                                                  ? OptimizedCacheImageProvider(
                                                      "${sharedPrefs.coverPicUrl}")
                                                  : FileImage(new File(
                                                      newCoverImagePath)),
                                              fit: BoxFit.cover),
                                        ),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.zero,
                                                child: RawMaterialButton(
                                                  onPressed: () =>
                                                      _chooseCoverImage(),
                                                  constraints:
                                                      BoxConstraints.expand(
                                                          width: 108,
                                                          height: 108),
                                                  elevation: 0,
                                                  child: Center(
                                                      child: Icon(
                                                    FontAwesomeIcons.penAlt,
                                                    color: Colors.white,
                                                    size: 32.0,
                                                  )),
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 36),
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
                                    ))),
                            Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.rectangle,
                                    border: Border.all(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/change_password_settings');
                                    },
                                    child: Container(
                                        height: 64,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Change Password",
                                            style: TextStyle(
                                                fontFamily: 'Lato',
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        )),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(top: 24, bottom: 24),
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    border: Border.all(color: Colors.white),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: FlatButton(
                                    onPressed: () => _saveProfileChanges(),
                                    child: Container(
                                        height: 64,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Save Changes",
                                            style: TextStyle(
                                                fontFamily: 'Lato',
                                                color: Colors.deepPurple,
                                                fontSize: 18),
                                          ),
                                        )),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    )))
          ],
        )));
  }
}
