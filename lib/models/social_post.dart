import 'package:groovenation_flutter/models/social_person.dart';

class SocialPost {
  final String postID; 
  final SocialPerson person;
  final String clubID; //Nullable
  final String clubName; //Nullable
  final int likesAmount;
  final String caption;
  final bool hasUserLiked;

  final int postType;
  final String mediaURL;

  SocialPost(this.postID, this.person, this.clubID, this.clubName, this.likesAmount,
      this.caption, this.hasUserLiked, this.postType, this.mediaURL);

  factory SocialPost.fromJson(dynamic json) {
    return SocialPost(
      json['postID'],
      SocialPerson.fromJson(json['person']),
      json['clubID'],
      json['clubName'],
      json['likesAmount'],
      json['caption'],
      json['hasUserLiked'],
      json['postType'],
      json['mediaURL'],
    );
  }

  Map toJson() => {
        "postID": postID,
        "person": person.toJson(),
        "clubID": clubID,
        "clubName": clubName,
        "likesAmount": likesAmount,
        "caption": caption,
        "hasUserLiked": hasUserLiked,
        "postType": postType,
        "mediaURL": mediaURL,
      };
}
