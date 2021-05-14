import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/change_password_cubit.dart';
import 'package:groovenation_flutter/cubit/state/change_password_state.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';

class ChangePasswordSettingsPage extends StatefulWidget {
  @override
  _ChangePasswordSettingsPageState createState() =>
      _ChangePasswordSettingsPageState();
}

class _ChangePasswordSettingsPageState
    extends State<ChangePasswordSettingsPage> {
  final oldPassowrdController = TextEditingController();
  final newPassowrdController = TextEditingController();
  final newMatchPassowrdController = TextEditingController();

  _saveNewPassword() {
    if (newPassowrdController.text != newMatchPassowrdController.text) {
      _showAlertDialog(BASIC_ERROR_TITLE, NEW_PASSWORDS_ERROR_PROMPT);
      return;
    }
    _showLoadingDialog(context);

    final ChangePasswordCubit changePasswordCubit =
        BlocProvider.of<ChangePasswordCubit>(context);
    if (!(changePasswordCubit.state is ChangePasswordLoadingState))
      changePasswordCubit.changePassword(
          oldPassowrdController.text, newPassowrdController.text);
  }

  Future<void> _showAlertDialog(String title, String desc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontFamily: 'Lato'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(desc, style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _isLoadingVisible = false;
  Future<void> _showLoadingDialog(BuildContext context) async {
    _isLoadingVisible = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(_keyLoader, "Processing...");
        });
  }

  _hideLoadingDialog() {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccessState) {
            _hideLoadingDialog();
            Navigator.pop(context);
          } else if (state is ChangePasswordErrorState) {
            _hideLoadingDialog();
            switch (state.error) {
              case Error.NETWORK_ERROR:
                _showAlertDialog(BASIC_ERROR_TITLE, NETWORK_ERROR_PROMPT);
                break;
              default:
                _showAlertDialog(BASIC_ERROR_TITLE, UNKNOWN_ERROR_PROMPT);
                break;
            }
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
                                    padding: EdgeInsets.zero,
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
                                  "Change Password",
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
                          padding: EdgeInsets.only(top: 16, bottom: 8),
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontFamily: 'Lato',
                                  ),
                                  autofocus: true,
                                  obscureText: true,
                                  controller: oldPassowrdController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    labelText: "Enter Current Password",
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
                              child: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontFamily: 'Lato',
                                  ),
                                  controller: newPassowrdController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    labelText: "Enter New Password",
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
                              child: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontFamily: 'Lato',
                                  ),
                                  obscureText: true,
                                  controller: newMatchPassowrdController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 24),
                                    labelText: "Confirm New Password",
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
                                    onPressed: _saveNewPassword(),
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
