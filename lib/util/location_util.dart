import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/constants/user_location_status.dart';
import 'package:location/location.dart';

class LocationUtil {
  LocationData userLocation;
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

  double getDefaultCityLat(String userCity) {
    //TODO City Lat
    if (userCity == CITY_JOHANNESBURG)
      return -26.07598127940465;
    else
      return -26.07598127940465;
  }

  double getDefaultCityLon(String userCity) {
    //TODO City Lon
    if (userCity == CITY_JOHANNESBURG)
      return 27.91605082698467;
    else
      return 27.91605082698467;
  }
}

final locationUtil = LocationUtil();
