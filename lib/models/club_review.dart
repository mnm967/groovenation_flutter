import 'package:groovenation_flutter/models/social_person.dart';

class ClubReview {
  final SocialPerson person;
  final double rating;
  final String review;

  ClubReview(this.person, this.rating, this.review);

  factory ClubReview.fromJson(dynamic json) {
    return ClubReview(
      SocialPerson.fromJson(json['person']),
      json['rating'],
      json['review'],
    );
  }

  Map toJson() => {
    "person" : person.toJson(),
    "rating" : rating,
    "review" : review,
  };
}
