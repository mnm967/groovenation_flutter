import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final GlobalKey _keyLoader;
  final String _promptText;
  LoadingDialog(this._keyLoader, this._promptText);

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
            key: _keyLoader,
            backgroundColor: Colors.purple,
            contentPadding: EdgeInsets.symmetric(vertical: 32),
            children: <Widget>[
              Center(
                child: Column(children: [
                  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    _promptText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                                fontFamily: 'LatoLight',
                                ),
                  )
                ]),
              )
            ]));
  }
}
