import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/cubit/state/auth_state.dart';
import 'package:groovenation_flutter/util/alert_util.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';
import 'package:groovenation_flutter/widgets/text_material_button_widget.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextStyle formFieldTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: 'Lato',
  );
  DateTime? selectedDate;
  TextEditingController myController = TextEditingController();

  final _focusNode = FocusNode();

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url, forceWebView: true)
      : alertUtil.sendAlert(
          BASIC_ERROR_TITLE, CANNOT_LAUNCH_URL_PROMPT, Colors.red, Icons.error);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
        authCubit.checkUsernameExists(usernameController.text);
      }
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
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
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1000),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      print(DateFormat.yMMMd().format(picked));
      myController.text = DateFormat.yMMMd().format(picked);
      setState(() {
        selectedDate = picked;
      });
    }
  }

  UsernameInputStatus? usernameInputStatus;

  InputDecoration textFieldDecor(
      String hintText, bool isPassword, bool isPublicUsername, bool isDate) {
    IconButton dateIcon = IconButton(
        icon: Icon(Icons.date_range),
        color: Colors.white,
        padding: EdgeInsets.only(right: 10),
        onPressed: () {});

    IconButton passwordIcon = IconButton(
        icon:
            Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
        color: Colors.white,
        padding: EdgeInsets.only(right: 10),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        });

    Visibility publicUsernameIcon = Visibility(
        visible: usernameInputStatus != UsernameInputStatus.NONE,
        child: Stack(children: [
          Visibility(
              visible: (usernameInputStatus ==
                      UsernameInputStatus.USERNAME_AVAILABLE ||
                  usernameInputStatus ==
                      UsernameInputStatus.USERNAME_UNAVAILABLE),
              child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircleAvatar(
                          backgroundColor: (usernameInputStatus ==
                                  UsernameInputStatus.USERNAME_AVAILABLE)
                              ? Colors.green
                              : Colors.red,
                          child: IconButton(
                              icon: Icon(
                                (usernameInputStatus ==
                                        UsernameInputStatus.USERNAME_AVAILABLE)
                                    ? Icons.check
                                    : Icons.close,
                                size: 24,
                              ),
                              color: Colors.white,
                              padding: EdgeInsets.zero,
                              onPressed: () {}))))),
          Visibility(
              visible: (usernameInputStatus ==
                  UsernameInputStatus.CHECKING_USERNAME),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      strokeWidth: 2,
                    ),
                  )))
        ]));

    Object? suffixButton;
    if (isPassword) suffixButton = passwordIcon;
    if (isPublicUsername) suffixButton = publicUsernameIcon;
    if (isDate) suffixButton = dateIcon;

    return InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
            borderSide: const BorderSide(color: Colors.white, width: 1.0)),
        disabledBorder: OutlineInputBorder(
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
        suffixIcon: suffixButton as Widget?);
  }

  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordMatchController = TextEditingController();

  bool pendingSignup = false;
  _executeSignup() {
    if (usernameInputStatus == UsernameInputStatus.CHECKING_USERNAME) {
      pendingSignup = true;
      return;
    }

    _showLoadingDialog(context);
    final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.signup(
        emailController.text,
        firstNameController.text,
        lastNameController.text,
        usernameController.text,
        passwordController.text,
        selectedDate!);
  }

  void _openNextPage() {
    _hideLoadingDialog();
    Navigator.pushReplacementNamed(context, '/city_picker');
  }

  void _openLoginPage() {
    Navigator.pushReplacementNamed(context, '/log');
  }

  void _displayError(state) {
    String desc;
    switch (state.error) {
      case AuthError.EMAIL_EXISTS_ERROR:
        desc = EMAIL_EXISTS_PROMPT;
        break;
      case AuthError.USERNAME_EXISTS_ERROR:
        desc = USERNAME_EXISTS_PROMPT;
        break;
      default:
        desc = UNKNOWN_ERROR_PROMPT;
    }
    _hideLoadingDialog();
    _showAlertDialog(BASIC_ERROR_TITLE, desc);
  }

  void _checkUsernameComplete(state) {
    setState(() {
      usernameInputStatus = state.usernameInputStatus;
    });

    if (pendingSignup) {
      pendingSignup = false;
      if (usernameInputStatus == UsernameInputStatus.USERNAME_AVAILABLE ||
          usernameInputStatus == UsernameInputStatus.NONE) {
        _showLoadingDialog(context);
        final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
        authCubit.signup(
            emailController.text,
            firstNameController.text,
            lastNameController.text,
            usernameController.text,
            passwordController.text,
            selectedDate!);
      } else if (usernameInputStatus ==
          UsernameInputStatus.USERNAME_UNAVAILABLE) {
        _hideLoadingDialog();
        _showAlertDialog("Username Already Exists", USERNAME_EXISTS_PROMPT);
      }
    }
  }

  void _blocListener(context, state) {
    if (state is AuthSignupSuccessState)
      _openNextPage();
    else if (state is AuthSignupErrorState)
      _displayError(state);
    else if (state is AuthUsernameCheckCompleteState)
      _checkUsernameComplete(state);
    else if (state is AuthUsernameCheckLoadingState)
      setState(() {
        usernameInputStatus = UsernameInputStatus.CHECKING_USERNAME;
      });
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return BlocListener<AuthCubit, AuthState>(
      listener: _blocListener,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: new ListView(
            padding: EdgeInsets.only(top: 48),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _title(),
                    _signUpTitle(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 48),
                      child: Column(
                        children: [
                          _firstNameInput(),
                          _lastNameInput(),
                          _emailInput(),
                          _usernameInput(),
                          _passwordInput(),
                          _confirmPasswordInput(),
                          _dateOfBirth(),
                        ],
                      ),
                    ),
                    _termsButton(),
                    _policyButton(),
                    _createAccountButton(),
                    _accountPrompt(),
                    _loginButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateForm() {
    if (selectedDate == null) {
      _showAlertDialog(
          "Date of Birth Invalid", "Please enter your Date of Birth");
      return;
    }

    if ((DateTime.now().year - selectedDate!.year) < 16) {
      _showAlertDialog("You are too young!",
          "You must be at least 16 years old to use GrooveNation. See more in our terms and conditions of use.");
      return;
    }

    if (_formKey.currentState!.validate()) {
      _executeSignup();
    }
  }

  Widget _accountPrompt() {
    return Padding(
      padding: EdgeInsets.only(top: 48),
      child: Text(
        "Already Have an Account?",
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontFamily: 'LatoLight',
        ),
      ),
    );
  }

  Widget _signUpTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kirvy',
            fontSize: 42,
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Center(
      child: Text(
        'GrooveNation',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'KirvyBold',
          fontSize: 50,
        ),
      ),
    );
  }

  Widget _createAccountButton() {
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
              onPressed: _validateForm,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
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

  Widget _loginButton() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 24),
      child: TextMaterialButton(
        onTap: _openLoginPage,
        child: Text(
          "Log In",
          style: TextStyle(
            color: Color(0xffE65AB9),
            fontSize: 20,
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }

  Widget _firstNameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: TextFormField(
          controller: firstNameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter Some Text';
            }

            if (value.length < 5 || value.length > 25) {
              return 'Enter a value between 5 - 25 characters';
            }
            return null;
          },
          style: formFieldTextStyle,
          decoration: textFieldDecor('First Name', false, false, false)),
    );
  }

  Widget _lastNameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextFormField(
        controller: lastNameController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Enter Some Text';
          }

          if (value.length < 5 || value.length > 25) {
            return 'Enter a value between 5 - 25 characters';
          }
          return null;
        },
        style: formFieldTextStyle,
        decoration: textFieldDecor("Last Name", false, false, false),
      ),
    );
  }

  Widget _emailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextFormField(
          controller: emailController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter Some Text';
            }

            if (value.length < 5 || value.length > 25) {
              return 'Enter a value between 5 - 25 characters';
            }

            return null;
          },
          style: formFieldTextStyle,
          decoration: textFieldDecor("Email", false, false, false)),
    );
  }

  Widget _usernameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextFormField(
          controller: usernameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter Some Text';
            }

            if (value.length < 5 || value.length > 25) {
              return 'Enter a value between 5 - 25 characters';
            }

            if (value.contains(" "))
              return "Spaces are not allowed in your username";

            if (usernameInputStatus ==
                UsernameInputStatus.USERNAME_UNAVAILABLE) {
              return 'This username has already been taken';
            }
            return null;
          },
          focusNode: _focusNode,
          style: formFieldTextStyle,
          decoration: textFieldDecor("Public Username", false, true, false)),
    );
  }

  Widget _passwordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextFormField(
        controller: passwordController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Enter Some Text';
          }

          if (value.length < 5 || value.length > 30) {
            return 'Enter a value between 5 - 30 characters';
          }
          return null;
        },
        style: formFieldTextStyle,
        decoration: textFieldDecor('Password', true, false, false),
        obscureText: !_isPasswordVisible,
      ),
    );
  }

  Widget _confirmPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextFormField(
        controller: passwordMatchController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please Enter Some Text';
          }
          if (passwordController.text != passwordMatchController.text) {
            return 'Passwords Do Not Match';
          }
          return null;
        },
        style: formFieldTextStyle,
        decoration: textFieldDecor('Confirm Password', false, false, false),
        obscureText: true,
      ),
    );
  }

  Widget _dateOfBirth() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextButton(
        onPressed: () {
          _selectDateOfBirth(context);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        child: TextFormField(
          enabled: false,
          style: formFieldTextStyle,
          decoration: textFieldDecor('Date of Birth', false, false, true),
          controller: myController,
          readOnly: true,
        ),
      ),
    );
  }

  Widget _termsButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16, top: 16),
      child: TextMaterialButton(
        onTap: () => _launchURL(TERMS_AND_CONDITIONS_LINK),
        child: Text(
          "View Terms and Conditions",
          style: TextStyle(
            color: Color(0xffE65AB9),
            fontSize: 21,
            fontFamily: 'LatoLight',
          ),
        ),
      ),
    );
  }

  Widget _policyButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: TextMaterialButton(
        onTap: () => _launchURL(PRIVACY_POLICY_LINK),
        child: Text(
          "View Privacy Policy",
          style: TextStyle(
            color: Color(0xffE65AB9),
            fontSize: 20,
            fontFamily: 'LatoLight',
          ),
        ),
      ),
    );
  }
}
