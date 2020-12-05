import 'dart:convert';

import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_post.dart';

class Club {
  final String clubID;
  final String name;
  final double averageRating;
  final String address;
  final String phoneNumber;
  final bool isUserFavourite;

  final List<Event> upcomingEvents;
  final List<String> images;
  final List<SocialPost> moments;
  final List<ClubReview> reviews;

  final ClubReview userReview; //Nullable

  final double latitude;
  final double longitude;

  final String webLink; //Nullable
  final String facebookLink; //Nullable
  final String twitterLink; //Nullable
  final String instagramLink; //Nullable

  Club(
    this.clubID,
    this.name,
    this.averageRating,
    this.address,
    this.phoneNumber,
    this.isUserFavourite,
    this.upcomingEvents,
    this.images,
    this.moments,
    this.reviews,
    this.userReview,
    this.latitude,
    this.longitude,
    this.webLink,
    this.facebookLink,
    this.twitterLink,
    this.instagramLink,
  );

  factory Club.fromJson(dynamic json) {
    return Club(
      json['clubID'],
      json['name'],
      json['averageRating'],
      json['address'],
      json['phoneNumber'],
      json['isUserFavourite'],
      (jsonDecode(json['upcomingEvents']) as List)
            .map((e) => Event.fromJson(e))
            .toList(),
      (jsonDecode(json['images']) as List)
            .map((e) => e.toString())
            .toList(),
      (jsonDecode(json['moments']) as List)
            .map((e) => SocialPost.fromJson(e))
            .toList(),
      (jsonDecode(json['reviews']) as List)
            .map((e) => ClubReview.fromJson(e))
            .toList(),
      json['userReview'] == null ? null : ClubReview.fromJson(json['userReview']),
      json['latitude'],
      json['longitude'],
      json['webLink'],
      json['facebookLink'],
      json['twitterLink'],
      json['instagramLink']
    );
  }

  Map toJson() {
    return {
      "clubID": clubID,
      "name": name,
      "averageRating": averageRating,
      "address": address,
      "phoneNumber": phoneNumber,
      "isUserFavourite": isUserFavourite,
      "upcomingEvents": jsonEncode(upcomingEvents),
      "images": jsonEncode(images),
      "moments": jsonEncode(moments),
      "reviews": jsonEncode(reviews),
      "userReview": userReview == null ? null : userReview.toJson(),
      "latitude": latitude,
      "longitude": longitude,
      "webLink": webLink,
      "facebookLink": facebookLink,
      "twitterLink": twitterLink,      
      "instagramLink": instagramLink,      
    };
  }
}
