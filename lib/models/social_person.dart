import 'package:hive/hive.dart';

part 'social_person.g.dart';

@HiveType(typeId: 2)
class SocialPerson {
  @HiveField(0)
  final String? personID;

  @HiveField(1)
  final String? personUsername;

  @HiveField(2)
  final String? personProfilePicURL;

  @HiveField(3)
  final String? personCoverPicURL;

  @HiveField(4)
  bool? isUserFollowing;

  @HiveField(5)
  bool? hasUserBlocked;

  SocialPerson(
      this.personID,
      this.personUsername,
      this.personProfilePicURL,
      this.personCoverPicURL,
      this.isUserFollowing,
      this.hasUserBlocked);

  factory SocialPerson.fromJson(dynamic json) {
    return SocialPerson(
      json['personID'],
      json['personUsername'],
      json['personProfilePicURL'],
      json['personCoverPicURL'],
      json['isUserFollowing'],
      json['hasUserBlocked'],
    );
  }

  Map toJson() => {
        "personID": personID,
        "personUsername": personUsername,
        "personProfilePicURL": personProfilePicURL,
        "personCoverPicURL": personCoverPicURL,
        "isUserFollowing": isUserFollowing,
        "hasUserBlocked": hasUserBlocked
      };
}
