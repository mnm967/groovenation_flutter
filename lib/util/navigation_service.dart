import 'package:flutter/cupertino.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Function? onChatResumeCallback;
  static Function? onConvResumeCallback;
}
