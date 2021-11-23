import 'package:flutter/material.dart';
import 'package:groovenation_flutter/util/hive_box_provider.dart';

class HiveLifecycleManager extends StatefulWidget {
  final Widget child;

  HiveLifecycleManager({required this.child});

  @override
  _HiveLifecycleManagerState createState() => _HiveLifecycleManagerState();
}

class _HiveLifecycleManagerState extends State<HiveLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        HiveBoxProvider.close().then((value) => HiveBoxProvider.init());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        HiveBoxProvider.close();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}