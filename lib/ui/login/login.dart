import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovenation_flutter/widgets/text_material_button_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextStyle formFieldTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: 'Lato',
  );

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
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
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                color: Colors.white,
                padding: EdgeInsets.only(right: 10),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }));
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
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
                      Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(right: 3),
                                    child: Container(
                                        child: Container(
                                      height: 61,
                                      child: Card(
                                        elevation: 5,
                                        color: Color(0xff1E88E5),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        semanticContainer: true,
                                        child: FlatButton(
                                            onPressed: () {
                                              print("World");
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Center(
                                                  child: Text(
                                                "Facebook",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Lato',
                                                  fontSize: 16,
                                                ),
                                              )),
                                            )),
                                      ),
                                    )))),
                            new Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Container(
                                        child: Container(
                                      height: 61,
                                      child: Card(
                                        elevation: 5,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        semanticContainer: true,
                                        child: FlatButton(
                                            onPressed: () {
                                              print("Hello");
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Center(
                                                  child: Text(
                                                "Google",
                                                style: TextStyle(
                                                  color: Color(0xff1E88E5),
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Lato',
                                                  fontSize: 16,
                                                ),
                                              )),
                                            )),
                                      ),
                                    )))),
                          ],
                        ),
                      ),
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
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
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
                                validator: (value) {
                                  if (value.isEmpty) {
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
                      ),
                      Container(
                        child: Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextMaterialButton(
                                    onTap: () {
                                      print("I forgot");
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Color(0xffE65AB9),
                                          fontFamily: 'Lato',
                                          fontSize: 18),
                                    )),
                              ],
                            )),
                      ),
                      Padding(
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
                                  if (_formKey.currentState.validate()) {
                                    print("Form is Valid");
                                  } else {
                                    print("Form is Not Valid");
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
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Text(
                          "Don't Have an Account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontFamily: 'LatoLight',
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 24),
                          child: TextMaterialButton(
                            onTap: () {
                              print("Open Sign Up");
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xffE65AB9),
                                fontSize: 20,
                                fontFamily: 'Lato',
                              ),
                            ),
                          )),
                    ]),
                  )
                ])));
  }
}
