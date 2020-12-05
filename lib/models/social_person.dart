class SocialPerson {
  final String personID;
  final String personUsername;
  final String personProfilePicURL;
  final String personCoverPicURL;
  final bool isUserFollowing;
  final bool hasUserBlocked;

  SocialPerson(this.personID, this.personUsername, this.personProfilePicURL,
      this.personCoverPicURL, this.isUserFollowing, this.hasUserBlocked);

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
        "hasUserBlocked": hasUserBlocked,
      };
}
