import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/error.dart';
import 'package:groovenation_flutter/cubit/auth_cubit.dart';
import 'package:groovenation_flutter/cubit/change_password_cubit.dart';
import 'package:groovenation_flutter/cubit/club_reviews_cubit.dart';
import 'package:groovenation_flutter/cubit/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/events_cubit.dart';
import 'package:groovenation_flutter/cubit/profile_settings_cubit.dart';
import 'package:groovenation_flutter/cubit/social_comments_cubit.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/cubit/ticket_purchase_cubit.dart';
import 'package:groovenation_flutter/cubit/tickets_cubit.dart';
import 'package:groovenation_flutter/cubit/user_cubit.dart';
import 'package:groovenation_flutter/data/repo/auth_repository.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/data/repo/ticket_repository.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';
import 'package:groovenation_flutter/util/location_util.dart';
import 'package:groovenation_flutter/util/shared_prefs.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );
  await locationUtil.init();
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://f834be9ae7964ee3a96fc777800c9bcf@o405222.ingest.sentry.io/5772349';
    },
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NearbyClubsCubit(ClubsRepository())),
        BlocProvider(create: (context) => TopClubsCubit(ClubsRepository())),
        BlocProvider(create: (context) => FavouritesClubsCubit(ClubsRepository())),
        BlocProvider(create: (context) => EventPageClubCubit(ClubsRepository())),
        BlocProvider(create: (context) => SearchClubsCubit(ClubsRepository())),
        BlocProvider(create: (context) => FavouritesEventsCubit(EventsRepository())),
        BlocProvider(create: (context) => ClubEventsCubit(EventsRepository())),
        BlocProvider(create: (context) => UpcomingEventsCubit(EventsRepository())),
        BlocProvider(create: (context) => SearchEventsCubit(EventsRepository())),
        BlocProvider(create: (context) => TicketsCubit(TicketsRepository())),
        BlocProvider(create: (context) => NearbySocialCubit(SocialRepository())),
        BlocProvider(create: (context) => FollowingSocialCubit(SocialRepository())),
        BlocProvider(create: (context) => TrendingSocialCubit(SocialRepository())),
        BlocProvider(create: (context) => SocialCommentsCubit(SocialRepository())),
        BlocProvider(create: (context) => UserSocialCubit(SocialRepository())),
        BlocProvider(create: (context) => SocialPostCubit(SocialRepository())),
        BlocProvider(create: (context) => SearchUsersCubit(SocialRepository())),
        BlocProvider(create: (context) => ClubMomentsCubit(SocialRepository())),
        BlocProvider(create: (context) => SocialCommentsLikeCubit(SocialRepository())),
        BlocProvider(create: (context) => ChangePasswordCubit(SocialRepository())),
        BlocProvider(create: (context) => ClubReviewsCubit(ClubsRepository())),
        BlocProvider(create: (context) => AddClubReviewCubit(ClubsRepository())),
        BlocProvider(create: (context) => AuthCubit(AuthRepository())),
        BlocProvider(create: (context) => ProfileSocialCubit(SocialRepository())),
        BlocProvider(create: (context) => ProfileSettingsCubit(SocialRepository())),
        BlocProvider(create: (context) => TicketPurchaseCubit(TicketsRepository())),
        BlocProvider(create: (context) => UserCubit(SocialRepository())),
      ],
      child: Directionality(textDirection: TextDirection.ltr,child: MainAppPage()),
    );
  }
}
