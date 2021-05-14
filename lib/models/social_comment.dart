import 'package:groovenation_flutter/models/social_person.dart';

class SocialComment {
  final SocialPerson person;
  final DateTime postTime;
  final int likesAmount;
  final bool hasUserLiked;
  final String comment;

  SocialComment(this.person, this.postTime, this.likesAmount, this.hasUserLiked,
      this.comment);

  factory SocialComment.fromJson(dynamic json) {
    return SocialComment(
      SocialPerson.fromJson(json['person']),
      DateTime.parse(json['postTime']),
      json['likesAmount'],
      json['hasUserLiked'],
      json['comment'],
    );
  }
}
