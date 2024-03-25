import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/cubit/chat/conversations_cubit.dart';
import 'package:groovenation_flutter/cubit/club/club_events_cubit.dart';
import 'package:groovenation_flutter/cubit/club/club_moments_cubit.dart';
import 'package:groovenation_flutter/cubit/club/club_reviews_cubit.dart';
import 'package:groovenation_flutter/cubit/event/event_club_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_events_cubit.dart';
import 'package:groovenation_flutter/cubit/search/search_users_cubit.dart';
import 'package:groovenation_flutter/cubit/social/profile_social_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_comments_like_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_post_cubit.dart';
import 'package:groovenation_flutter/data/repo/chat_repository.dart';
import 'package:groovenation_flutter/cubit/user/auth_cubit.dart';
import 'package:groovenation_flutter/cubit/user/change_password_cubit.dart';
import 'package:groovenation_flutter/cubit/club/clubs_cubit.dart';
import 'package:groovenation_flutter/cubit/event/events_cubit.dart';
import 'package:groovenation_flutter/cubit/user/profile_settings_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_comments_cubit.dart';
import 'package:groovenation_flutter/cubit/social/social_cubit.dart';
import 'package:groovenation_flutter/cubit/tickets/ticket_purchase_cubit.dart';
import 'package:groovenation_flutter/cubit/tickets/tickets_cubit.dart';
import 'package:groovenation_flutter/cubit/user/user_cubit.dart';
import 'package:groovenation_flutter/data/repo/auth_repository.dart';
import 'package:groovenation_flutter/data/repo/clubs_repository.dart';
import 'package:groovenation_flutter/data/repo/events_repository.dart';
import 'package:groovenation_flutter/data/repo/social_repository.dart';
import 'package:groovenation_flutter/data/repo/ticket_repository.dart';
import 'package:groovenation_flutter/ui/screens/main_app_page.dart';
import 'package:groovenation_flutter/util/hive_lifecycle_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'cubit/event/events_cubit.dart';
import 'data/repo/events_repository.dart';

class GroovenationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HiveLifecycleManager(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => NearbyClubsCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => TopClubsCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => UserSocialCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => SocialPostCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => SearchUsersCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => ClubMomentsCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => UserListCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => ConversationsCubit(ChatRepository()),
          ),
          BlocProvider(
            create: (context) => ClubReviewsCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => AuthCubit(AuthRepository()),
          ),
          BlocProvider(
            create: (context) => FavouritesClubsCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => EventClubCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => SearchClubsCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => FavouritesEventsCubit(EventsRepository()),
          ),
          BlocProvider(
            create: (context) => ClubEventsCubit(EventsRepository()),
          ),
          BlocProvider(
            create: (context) => UpcomingEventsCubit(EventsRepository()),
          ),
          BlocProvider(
            create: (context) => SearchEventsCubit(EventsRepository()),
          ),
          BlocProvider(
            create: (context) => TicketsCubit(TicketsRepository()),
          ),
          BlocProvider(
            create: (context) => NearbySocialCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => FollowingSocialCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => TrendingSocialCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => SocialCommentsCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => SocialCommentsLikeCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => ChangePasswordCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => AddClubReviewCubit(ClubsRepository()),
          ),
          BlocProvider(
            create: (context) => ProfileSocialCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => ProfileSettingsCubit(SocialRepository()),
          ),
          BlocProvider(
            create: (context) => TicketPurchaseCubit(TicketsRepository()),
          ),
          BlocProvider(
            create: (context) => UserCubit(SocialRepository()),
          ),
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Localizations(
            locale: Locale('en'),
            delegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            child: MainAppPage(),
          ),
        ),
      ),
    );
  }
}
