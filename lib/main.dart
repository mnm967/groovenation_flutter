import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedCubit.storage = await HydratedStorage.build();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NearbyClubsCubit(ClubsRepository())
        ),
        BlocProvider(
          create: (context) => TopClubsCubit(ClubsRepository())
        ),
        BlocProvider(
          create: (context) => FavouritesClubsCubit(ClubsRepository())
        ),
        BlocProvider(
          create: (context) => FavouritesEventsCubit(EventsRepository())
        ),
        BlocProvider(
          create: (context) => UpcomingEventsCubit(EventsRepository())
        ),
      ], 
      child: MaterialApp(
              title: 'GrooveNation',
              theme: ThemeData(
                primarySwatch: Colors.purple,
              ),
              home: MainAppPage(),
            ),
    );
    // return MaterialApp(
    //   title: 'GrooveNation',
    //   theme: ThemeData(
    //     primarySwatch: Colors.purple,
    //   ),
    //   home: MainAppPage(),
    // );
  }
}
