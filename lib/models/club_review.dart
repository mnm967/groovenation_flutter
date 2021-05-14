import 'package:groovenation_flutter/models/social_person.dart';

class ClubReview {
  final SocialPerson person;
  num rating;
  String review;

  ClubReview(this.person, this.rating, this.review);

  factory ClubReview.fromJson(dynamic json) {
    return ClubReview(
      json['person'] == null ? null : SocialPerson.fromJson(json['person']),
      json['rating'],
      json['review'],
    );
  }

  Map toJson() => {
    "person" : person == null ? null : person.toJson(),
    "rating" : rating,
    "review" : review,
  };
}
