import 'package:flutter/material.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';

class AlertUtil {
  static MainAppPageState mainAppPageState;

  init(MainAppPageState state) {
    mainAppPageState = state;
  }

  sendAlert(
    String title,
    String text,
    Color backgroundColor,
    IconData icon,
  ) {
    mainAppPageState.openDialog(title, text, backgroundColor, icon);
  }
}

final alertUtil = AlertUtil();
