import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/state/auth_state.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/models/city.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CityPickerSettingsPage extends StatefulWidget {
  @override
  _CityPickerSettingsPageState createState() => _CityPickerSettingsPageState();
}

class _CityPickerSettingsPageState extends State<CityPickerSettingsPage> {
  @override
  void initState() {
    super.initState();

    AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.getAvailableCities();
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
                  _title(),
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

  Widget _title() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(900)),
            child: FlatButton(
              padding: EdgeInsets.only(left: 8),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 36, top: 16),
          child: Text(
            "Choose A City",
            style: TextStyle(
                color: Colors.white, fontSize: 36, fontFamily: 'LatoBold'),
          ),
        ),
      ],
    );
  }

  String? _selectedCity = sharedPrefs.userCity;
  double? _selectedDefaultLat = sharedPrefs.defaultLat;
  double? _selectedDefaultLon = sharedPrefs.defaultLon;

  _saveSelectedCity(BuildContext c) {
    sharedPrefs.userCity = _selectedCity;
    sharedPrefs.defaultLat = _selectedDefaultLat;
    sharedPrefs.defaultLon = _selectedDefaultLon;

    Navigator.pop(c);
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
        child: FlatButton(
          onPressed: () {
            _selectedCity = city.cityID;
            _selectedDefaultLat = city.defaultLat;
            _selectedDefaultLon = city.defaultLon;

            _saveSelectedCity(context);
          },
          padding: EdgeInsets.zero,
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
                            Padding(
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                height: 64,
                                width: 64,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Colors.purple.withOpacity(0.5),
                                  backgroundImage: CachedNetworkImageProvider(
                                      city.imageUrl!),
                                ),
                              ),
                            ),
                            Expanded(
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
                                            padding: EdgeInsets.only(
                                                left: 4, right: 3),
                                            child: Text(
                                              city.name!,
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
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
