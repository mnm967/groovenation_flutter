import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/cubit/state/auth_state.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:groovenation_flutter/widgets/text_material_button_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final TextStyle formFieldTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: 'Lato',
  );

  @override
  void initState() {
    super.initState();
  }

  InputDecoration textFieldDecor(String hintText, bool isPassword) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Colors.white, width: 1.0)),
      errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Colors.red, width: 1.0)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Color(0xffE65AB9), width: 1.0)),
      errorStyle: TextStyle(fontFamily: 'Lato'),
      focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Color(0xffE65AB9), width: 1.0)),
      suffixIcon: !isPassword
          ? null
          : IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              color: Colors.white,
              padding: EdgeInsets.only(right: 10),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
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
          return LoadingDialog(_keyLoader, "Please Wait...");
        });
  }

  Future<void> _hideLoadingDialog() async {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      await Future.delayed(Duration(seconds: 1));
    }

    try {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
    } catch (e) {}
  }

  _openForgotPassword() {}

  _executeLogin() {
    _showLoadingDialog(context);
    final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.login(usernameController.text, passwordController.text);
  }

  _openSignUp() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  Future<void> _showAlertDialog(
      BuildContext context, String title, String desc) async {
    try {
      await _hideLoadingDialog();
    } catch (e) {}

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
              children: [
                Text(desc, style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: [
            TextButton(
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

  Future<void> _loginFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        _showLoadingDialog(context);
        final token = result.accessToken!.token;
        final graphResponse = await Dio().get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = jsonDecode(graphResponse.data.toString());

        String? name = profile['name'];
        String? email = profile['email'];
        String? facebookId = profile['id'];

        final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
        authCubit.loginFacebook(email, name, facebookId);
      } else if (result.status == LoginStatus.failed) {
        _showAlertDialog(context, "Something Went Wrong", UNKNOWN_ERROR_PROMPT);
      }
    } catch (e) {
      _hideLoadingDialog();
      _showAlertDialog(context, "Something Went Wrong", UNKNOWN_ERROR_PROMPT);
    }
  }

  Future<void> _loginGoogle() async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      _showLoadingDialog(context);

      String? name = googleSignInAccount!.displayName;
      String email = googleSignInAccount.email;
      String googleId = googleSignInAccount.id;

      final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
      authCubit.loginGoogle(email, name, googleId);
    } catch (e) {
      print(e);
      _showAlertDialog(context, "Something Went Wrong", UNKNOWN_ERROR_PROMPT);
    }
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccessState) {
          _hideLoadingDialog();
          if (sharedPrefs.userCity == null)
            Navigator.pushReplacementNamed(context, '/city_picker');
          else if (sharedPrefs.username == null)
            Navigator.pushReplacementNamed(context, '/create_username');
          else
            Navigator.pushReplacementNamed(context, '/main');
        } else if (state is AuthLoginErrorState) {
          String desc;
          switch (state.error) {
            case AuthError.LOGIN_FAILED:
              desc = LOGIN_FAILED_PROMPT;
              break;
            default:
              desc = UNKNOWN_ERROR_PROMPT;
          }
          _showAlertDialog(context, "Something Went Wrong", desc);
        }
      },
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: new ListView(
            padding: EdgeInsets.only(top: 48),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            children: [_mainPageForm()],
          ),
        ),
      ),
    );
  }

  Widget _mainPageForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: Text(
              'GrooveNation',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'KirvyBold',
                fontSize: 50,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                'Log In',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kirvy',
                  fontSize: 42,
                ),
              ),
            ),
          ),
          _socialLoginButtons(),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'LatoLight',
                  fontSize: 24,
                ),
              ),
            ),
          ),
          _textInputs(),
          _forgotPassword(),
          _loginButton(),
          _signupPrompt(),
          _signupButton()
        ],
      ),
    );
  }

  Widget _signupButton() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 24),
      child: TextMaterialButton(
        onTap: _openSignUp,
        child: Text(
          "Sign Up",
          style: TextStyle(
            color: Color(0xffE65AB9),
            fontSize: 20,
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }

  Widget _signupPrompt() {
    return Padding(
      padding: EdgeInsets.only(top: 48),
      child: Text(
        "Don't Have an Account?",
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontFamily: 'LatoLight',
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Container(
          child: Container(
        height: 61,
        child: Card(
          elevation: 0,
          color: Color(0xffE65AB9),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          semanticContainer: true,
          child: TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _executeLogin();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Center(
                    child: Text(
                  "Log In",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                )),
              )),
        ),
      )),
    );
  }

  Widget _forgotPassword() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextMaterialButton(
              onTap: () {
                _openForgotPassword();
              },
              child: Text(
                "Forgot Password?",
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: Color(0xffE65AB9), fontFamily: 'Lato', fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textInputs() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: TextFormField(
                controller: usernameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Enter Some Text';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontFamily: 'Lato',
                ),
                decoration: textFieldDecor("Email", false)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter Some Text';
                }
                return null;
              },
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'Lato',
              ),
              decoration: textFieldDecor("Password", true),
              obscureText: !_isPasswordVisible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isFacebook) {
    return new Expanded(
      child: Padding(
        padding:
            isFacebook ? EdgeInsets.only(right: 3) : EdgeInsets.only(left: 3),
        child: Container(
          child: Container(
            height: 61,
            child: Card(
              elevation: 5,
              color: isFacebook ? Color(0xff1E88E5) : Colors.white,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              semanticContainer: true,
              child: TextButton(
                onPressed:
                    isFacebook ? () => _loginFacebook() : () => _loginGoogle(),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFacebook
                              ? FontAwesomeIcons.facebookF
                              : FontAwesomeIcons.google,
                          color: isFacebook ? Colors.white : Color(0xff1E88E5),
                          size: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Text(
                          isFacebook ? "Facebook" : "Google",
                          style: TextStyle(
                            color:
                                isFacebook ? Colors.white : Color(0xff1E88E5),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 48),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_buildLoginButton(true), _buildLoginButton(false)],
      ),
    );
  }
}
