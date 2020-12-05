import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovenation_flutter/widgets/text_material_button_widget.dart';
import 'package:intl/intl.dart';

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
  DateTime selectedDate;
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
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
          title: Text(title, style: TextStyle(fontFamily: 'Lato'),),
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

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime picked = await showDatePicker(
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
        visible: false,
        child: Stack(children: [
          Visibility(
              visible: false,
              child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 24,
                              ),
                              color: Colors.white,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              }))))),
          Visibility(
              visible: true,
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

    Object suffixButton;
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
        suffixIcon: suffixButton);
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
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Kirvy',
                              fontSize: 42,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 8, top: 48),
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
                                  style: formFieldTextStyle,
                                  decoration: textFieldDecor(
                                      'First Name',
                                      false,
                                      false,
                                      false)),
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
                                  style: formFieldTextStyle,
                                  decoration: textFieldDecor(
                                      "Last Name",
                                      false,
                                      false,
                                      false)),
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
                                  style: formFieldTextStyle,
                                  decoration: textFieldDecor(
                                      "Public Username",
                                      false,
                                      true,
                                      false)),
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
                                style: formFieldTextStyle,
                                decoration: textFieldDecor(
                                    'Password', true, false, false),
                                obscureText: !_isPasswordVisible,
                              ),
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
                                style: formFieldTextStyle,
                                decoration: textFieldDecor(
                                    'Confirm Password',
                                    false,
                                    false,
                                    false),
                                obscureText: true,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: FlatButton(
                                  onPressed: () {
                                    print("DatePick");
                                    _selectDateOfBirth(context);
                                  },
                                  padding: EdgeInsets.all(0),
                                  splashColor:
                                      Colors.white.withOpacity(0.3),
                                  child: TextFormField(
                                    enabled: false,
                                    style: formFieldTextStyle,
                                    decoration: textFieldDecor(
                                        'Date of Birth',
                                        false,
                                        false,
                                        true),
                                    controller: myController,
                                    readOnly: true,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 16, top: 16),
                        child: TextMaterialButton(
                          onTap: () {
                            print("Open Terms and Conditions");
                          },
                          child: Text(
                            "View Terms and Conditions",
                            style: TextStyle(
                              color: Color(0xffE65AB9),
                              fontSize: 21,
                              fontFamily: 'LatoLight',
                            ),
                          ),
                      )),
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 8),
                        child: TextMaterialButton(
                          onTap: () {
                            print("Open Privacy Policy");
                          },
                          child: Text(
                            "View Privacy Policy",
                            style: TextStyle(
                              color: Color(0xffE65AB9),
                              fontSize: 20,
                              fontFamily: 'LatoLight',
                            ),
                          ),
                      )),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Container(
                            child: Container(
                          height: 61,
                          child: Card(
                            elevation: 0,
                            color: Color(0xffE65AB9),
                            clipBehavior:
                                Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10.0),
                            ),
                            semanticContainer: true,
                            child: FlatButton(
                                onPressed: () {
                                  if(selectedDate == null){
                                    _showAlertDialog("Date of Birth Invalid", "Please enter your Date of Birth");
                                    return;
                                  }
                                  
                                  if((DateTime.now().year - selectedDate.year) < 16){
                                    _showAlertDialog("You are too young!", "You must be at least 16 years old to use GrooveNation. See more in our terms and conditions of use.");
                                    return;
                                  }

                                  if (_formKey.currentState
                                      .validate()) {
                                    print("Form is Valid");
                                  } else {
                                    print("Form is Not Valid");
                                  }
                                },
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
                                  )),
                                )),
                          ),
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Text(
                          "Already Have an Account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontFamily: 'LatoLight',
                          ),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(top: 8, bottom: 24),
                          child: TextMaterialButton(
                            onTap: () {
                              print("Open Log In");
                            },
                            child: Text(
                              "Log In",
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
