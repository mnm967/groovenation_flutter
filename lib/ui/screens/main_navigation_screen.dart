import 'package:flutter/material.dart';
import 'package:groovenation_flutter/ui/screens/app_background_page.dart';
import 'package:groovenation_flutter/ui/screens/main_home_navigation.dart';

class MainNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: MainNavigationPage());
  }
}