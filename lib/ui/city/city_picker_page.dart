import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/auth_state.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/models/city.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:location/location.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CityPickerPage extends StatefulWidget {
  @override
  _CityPickerPageState createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  String? _selectedCity;
  double? _selectedDefaultLat;
  double? _selectedDefaultLon;

  @override
  void initState() {
    super.initState();

    AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.getAvailableCities();
  }

  Future<void> _showPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Location Permission",
            style: TextStyle(fontFamily: 'Lato'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "Optional: GrooveNation can use your location to provide more accurate data on nearby clubs and events. Will you allow GrooveNation to access your location when available?",
                    style: TextStyle(fontFamily: 'Lato')),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                sharedPrefs.userCity = _selectedCity;
                sharedPrefs.defaultLat = _selectedDefaultLat;
                sharedPrefs.defaultLon = _selectedDefaultLon;

                if (sharedPrefs.username != null)
                  Navigator.pushReplacementNamed(context, '/main');
                else
                  Navigator.pushReplacementNamed(context, '/create_username');
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () async {
                Location location = new Location();
                await location.requestPermission();

                sharedPrefs.userCity = _selectedCity;
                sharedPrefs.defaultLat = _selectedDefaultLat;
                sharedPrefs.defaultLon = _selectedDefaultLon;

                if (sharedPrefs.username != null)
                  Navigator.pushReplacementNamed(context, '/main');
                else
                  Navigator.pushReplacementNamed(context, '/create_username');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _circularProgress() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Center(
        child: SizedBox(
          height: 56,
          width: 56,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Colors.deepPurple);

    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      "Choose A City",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'LatoBold'),
                    ),
                  ),
                  BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                    List<City> cities = [];

                    if (state is AuthAvailableCitiesLoadingState) {
                      return _circularProgress();
                    } else if (state is AuthAvailableCitiesErrorState) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                        child: Text(
                          "Something Went Wrong. Please check your connection and try again",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              fontFamily: 'Lato'),
                        ),
                      );
                    }

                    if (state is AuthAvailableCitiesLoadedState)
                      cities = state.cities;

                    return ListView.builder(
                        padding: EdgeInsets.only(top: 16),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            child: Align(
                              child: _cityItem(context, cities[index]),
                              alignment: Alignment.topCenter,
                            ),
                          );
                        });
                  }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _cityItem(BuildContext context, City city) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Card(
        elevation: 4,
        color: Colors.deepPurple,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: TextButton(
          onPressed: () {
            _selectedCity = city.cityID;
            _selectedDefaultLat = city.defaultLat;
            _selectedDefaultLon = city.defaultLon;

            _showPermissionDialog();
          },
          child: Wrap(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _cityItemImage(city.imageUrl!),
                            _cityItemName(city.name!),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _cityItemImage(String imageUrl) {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 64,
        width: 64,
        child: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.5),
          backgroundImage: CachedNetworkImageProvider(imageUrl),
        ),
      ),
    );
  }

  Widget _cityItemName(String name) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, right: 3),
                    child: Text(
                      name,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'LatoBold',
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
