class SocialPerson {
  final String personID;
  final String personUsername;
  final String personProfilePicURL;
  final String personCoverPicURL;
  final bool isUserFollowing;
  final bool hasUserBlocked;
  final bool personBlockedUser;

  SocialPerson(this.personID, this.personUsername, this.personProfilePicURL,
      this.personCoverPicURL, this.isUserFollowing, this.hasUserBlocked, this.personBlockedUser);

  factory SocialPerson.fromJson(dynamic json) {
    return SocialPerson(
      json['personID'],
      json['personUsername'],
      json['personProfilePicURL'],
      json['personCoverPicURL'],
      json['isUserFollowing'],
      json['hasUserBlocked'],
      json['personBlockedUser'],
    );
  }

  Map toJson() => {
        "personID": personID,
        "personUsername": personUsername,
        "personProfilePicURL": personProfilePicURL,
        "personCoverPicURL": personCoverPicURL,
        "isUserFollowing": isUserFollowing,
        "hasUserBlocked": hasUserBlocked,
        "personBlockedUser": personBlockedUser,
      };
}
