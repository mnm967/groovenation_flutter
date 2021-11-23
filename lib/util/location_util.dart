import 'package:groovenation_flutter/constants/enums.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:location/location.dart';

class LocationUtil {
  late LocationData userLocation;
  UserLocationStatus userLocationStatus = UserLocationStatus.NOT_FOUND;

  init() async {
    try {
      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          userLocationStatus = UserLocationStatus.SERVICE_DISABLED;
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        userLocationStatus = UserLocationStatus.PERMISSION_NOT_GRANTED;
        return;
      }

      userLocation = await location.getLocation();
    } catch (e) {
      userLocationStatus = UserLocationStatus.UNKNOWN_ERROR;
    }
  }

  double getDefaultCityLat() {
    if (sharedPrefs.defaultLat != null)
      return sharedPrefs.defaultLat!;
    else
      return -26.07598127940465; //Default: Johannesburg
  }

  double getDefaultCityLon() {
    if (sharedPrefs.defaultLon != null)
      return sharedPrefs.defaultLon!;
    else
      return 27.91605082698467; //Default: Johannesburg
  }
}

final locationUtil = LocationUtil();
