import 'package:flutter/material.dart';
import 'package:groovenation_flutter/ui/screens/app_background_page.dart';
import 'package:groovenation_flutter/models/club.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/ui/chat/chat_page.dart';
import 'package:groovenation_flutter/ui/chat/conversations_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_page.dart';
import 'package:groovenation_flutter/ui/city/city_picker_settings_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_events_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_moments_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_page.dart';
import 'package:groovenation_flutter/ui/clubs/club_reviews_page.dart';
import 'package:groovenation_flutter/ui/events/event_page.dart';
import 'package:groovenation_flutter/ui/login/login.dart';
import 'package:groovenation_flutter/ui/profile/profile_page.dart';
import 'package:groovenation_flutter/ui/screens/main_home_navigation.dart';
import 'package:groovenation_flutter/ui/search/club_search.dart';
import 'package:groovenation_flutter/ui/search/search_page.dart';
import 'package:groovenation_flutter/ui/search/social_people_search.dart';
import 'package:groovenation_flutter/ui/settings/change_password_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/notification_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/profile_settings_page.dart';
import 'package:groovenation_flutter/ui/settings/settings_page.dart';
import 'package:groovenation_flutter/ui/sign_up/create_username.dart';
import 'package:groovenation_flutter/ui/sign_up/sign_up.dart';
import 'package:groovenation_flutter/ui/social/create_post_page.dart';
import 'package:groovenation_flutter/ui/social/following_page.dart';
import 'package:groovenation_flutter/util/chat_page_arguments.dart';
import 'package:groovenation_flutter/util/create_post_arguments.dart';

class MainNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: MainNavigationPage());
  }
}

class EventPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Event? event = ModalRoute.of(context)!.settings.arguments as Event?;
    return AppBackgroundPage(child: EventPage(event));
  }
}

class ClubPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club? club = ModalRoute.of(context)!.settings.arguments as Club?;
    return AppBackgroundPage(child: ClubPage(club));
  }
}

class ClubEventsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club? club = ModalRoute.of(context)!.settings.arguments as Club?;
    return AppBackgroundPage(child: ClubEventsPage(club));
  }
}

class ClubMomentsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club? club = ModalRoute.of(context)!.settings.arguments as Club?;
    return AppBackgroundPage(child: ClubMomentsPage(club));
  }
}

class ClubReviewsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Club? club = ModalRoute.of(context)!.settings.arguments as Club?;
    return AppBackgroundPage(child: ClubReviewsPage(club));
  }
}

class ConversationsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ConversationsPage());
  }
}

class ChatPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatPageArguments args = ModalRoute.of(context)!.settings.arguments as ChatPageArguments;
    return AppBackgroundPage(
        child: ChatPage(args.conversation, args.messageToSend));
  }
}

class LoginPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: LoginPage());
  }
}

class SignUpPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: SignUpPage());
  }
}

class CreateUsernamePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: CreateUsernamePage());
  }
}

class SearchPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: SearchPage());
  }
}

class SettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: SettingsPage());
  }
}

class NotificationSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: NotificationSettingsPage());
  }
}

class ProfileSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ProfileSettingsPage());
  }
}

class CityPickerPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: CityPickerPage());
  }
}

class FollowingPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: FollowingPage());
  }
}

class CreatePostPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CreatePostArguments args = ModalRoute.of(context)!.settings.arguments as CreatePostArguments;
    return AppBackgroundPage(
        child: CreatePostPage(args.mediaPath, args.isVideo));
  }
}

class ClubSearchPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Function? onClubSelected = ModalRoute.of(context)!.settings.arguments as Function?;
    return AppBackgroundPage(
        child: ClubSearchPage(
      onClubSelected: onClubSelected,
    ));
  }
}

class SocialPeopleSearchPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Function? onUserSelected = ModalRoute.of(context)!.settings.arguments as Function?;
    return AppBackgroundPage(
        child: SocialPeopleSearchPage(
      onUserSelected: onUserSelected,
    ));
  }
}

class CityPickerSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: CityPickerSettingsPage());
  }
}

class ChangePasswordSettingsPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackgroundPage(child: ChangePasswordSettingsPage());
  }
}

class ProfilePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SocialPerson? socialPerson = ModalRoute.of(context)!.settings.arguments as SocialPerson?;
    return AppBackgroundPage(child: ProfilePage(socialPerson));
  }
}
