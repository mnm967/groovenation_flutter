import 'package:groovenation_flutter/models/social_person.dart';

class SocialComment {
  final String? commentId;
  final SocialPerson person;
  final DateTime postTime;
  int? likesAmount;
  bool? hasUserLiked;
  final String? comment;

  SocialComment(this.commentId, this.person, this.postTime, this.likesAmount, this.hasUserLiked,
      this.comment);

  factory SocialComment.fromJson(dynamic json) {
    return SocialComment(
      json['commentId'],
      SocialPerson.fromJson(json['person']),
      DateTime.parse(json['postTime']),
      json['likesAmount'],
      json['hasUserLiked'],
      json['comment'],
    );
  }
}
