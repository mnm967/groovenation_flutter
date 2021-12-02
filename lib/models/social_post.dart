import 'package:groovenation_flutter/models/social_person.dart';

class SocialPost {
  final String? postID; 
  SocialPerson person;
  final String? clubID; //Nullable
  final String? clubName; //Nullable
  int? likesAmount;
  int? commentsAmount;
  final String? caption;
  bool? hasUserLiked;

  final int? postType;
  final String? mediaURL;

  SocialPost(this.postID, this.person, this.clubID, this.clubName, this.likesAmount,
      this.commentsAmount, this.caption, this.hasUserLiked, this.postType, this.mediaURL);

  factory SocialPost.fromJson(dynamic json) {
    return SocialPost(
      json['postID'],
      SocialPerson.fromJson(json['person']),
      json['clubID'],
      json['clubName'],
      json['likesAmount'],
      json['commentsAmount'],
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
        "commentsAmount": commentsAmount,
        "caption": caption,
        "hasUserLiked": hasUserLiked,
        "postType": postType,
        "mediaURL": mediaURL,
      };
}
