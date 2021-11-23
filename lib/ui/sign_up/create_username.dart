import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/cubit/state/auth_state.dart';
import 'package:groovenation_flutter/widgets/loading_dialog.dart';

class CreateUsernamePage extends StatefulWidget {
  @override
  _CreateUsernamePageState createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextStyle formFieldTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: 'Lato',
  );
  DateTime? selectedDate;
  TextEditingController _textController = TextEditingController();

  UsernameInputStatus? usernameInputStatus;
  final usernameController = TextEditingController();
  bool pendingExecution = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
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
          return LoadingDialog(_keyLoader, "Please Wait...");
        });
  }

  _hideLoadingDialog() {
    if (_isLoadingVisible) {
      _isLoadingVisible = false;
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
    }
  }

  Widget _publicUsernameIcon() {
    return Visibility(
      visible: usernameInputStatus != UsernameInputStatus.NONE,
      child: Stack(
        children: [
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
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible:
                (usernameInputStatus == UsernameInputStatus.CHECKING_USERNAME),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateIcon() {
    return IconButton(
      icon: Icon(Icons.date_range),
      color: Colors.white,
      padding: EdgeInsets.only(right: 10),
      onPressed: () {},
    );
  }

  Widget _passwordIcon() {
    return IconButton(
      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
      color: Colors.white,
      padding: EdgeInsets.only(right: 10),
      onPressed: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
    );
  }

  InputDecoration textFieldDecor(
      String hintText, bool isPassword, bool isPublicUsername, bool isDate) {
    IconButton dateIcon = _dateIcon() as IconButton;

    IconButton passwordIcon = _passwordIcon() as IconButton;

    Visibility publicUsernameIcon = _publicUsernameIcon() as Visibility;

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
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Color(0xffE65AB9), width: 1.0),
        ),
        errorStyle: TextStyle(fontFamily: 'Lato'),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: const BorderSide(color: Color(0xffE65AB9), width: 1.0),
        ),
        suffixIcon: suffixButton as Widget?);
  }

  void _createUsername() {
    if (usernameInputStatus == UsernameInputStatus.CHECKING_USERNAME) {
      pendingExecution = true;
      return;
    }

    _showLoadingDialog(context);
    final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.createUsername(usernameController.text);
  }

  void _openNextPage() {
    _hideLoadingDialog();
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _displayError(state) {
    String desc;
    switch (state.error) {
      case AuthError.USERNAME_EXISTS_ERROR:
        desc = USERNAME_EXISTS_PROMPT;
        break;
      default:
        desc = UNKNOWN_ERROR_PROMPT;
    }
    _hideLoadingDialog();
    _showAlertDialog(BASIC_ERROR_TITLE, desc);
  }

  void _usernameCheckCompleted(state) {
    setState(() {
      usernameInputStatus = state.usernameInputStatus;
    });

    if (pendingExecution) {
      pendingExecution = false;
      if (usernameInputStatus == UsernameInputStatus.USERNAME_AVAILABLE ||
          usernameInputStatus == UsernameInputStatus.NONE) {
        _showLoadingDialog(context);

        final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
        authCubit.createUsername(usernameController.text);
      } else if (usernameInputStatus ==
          UsernameInputStatus.USERNAME_UNAVAILABLE) {
        _hideLoadingDialog();
        _showAlertDialog("Username Already Exists", USERNAME_EXISTS_PROMPT);
      }
    }
  }

  void _blocListener(context, state) {
    if (state is AuthCreateUsernameSuccessState)
      _openNextPage();
    else if (state is AuthCreateUsernameErrorState)
      _displayError(state);
    else if (state is AuthUsernameCheckCompleteState)
      _usernameCheckCompleted(state);
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
                child: Column(children: [
                  _title(),
                  _usernameTextField(),
                  _createUsernameButton(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          'Create Username',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kirvy',
            fontSize: 42,
          ),
        ),
      ),
    );
  }

  Widget _usernameTextField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 48),
      child: Column(
        children: [
          Padding(
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
                onChanged: (value) {
                  final AuthCubit authCubit =
                      BlocProvider.of<AuthCubit>(context);
                  authCubit.checkUsernameExists(value);
                },
                style: formFieldTextStyle,
                decoration:
                    textFieldDecor("Public Username", false, true, false)),
          ),
        ],
      ),
    );
  }

  Widget _createUsernameButton() {
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
            child: FlatButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _createUsername();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Center(
                  child: Text(
                    "Create Username",
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
}
