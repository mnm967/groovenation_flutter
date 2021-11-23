import 'dart:convert';

import 'package:groovenation_flutter/models/club_promotion.dart';
import 'package:groovenation_flutter/models/club_review.dart';
import 'package:groovenation_flutter/models/event.dart';
import 'package:groovenation_flutter/models/social_post.dart';

class Club {
  final String? clubID;
  final String? name;
  num? averageRating;
  final String? address;
  final String? phoneNumber;

  final List<ClubPromotion>? clubPromotions;
  final List<Event> upcomingEvents;
  final List<String> images;
  final List<SocialPost> moments;
  final List<ClubReview> reviews;

  ClubReview? userReview; //Nullable
  int? totalReviews;

  final double? latitude;
  final double? longitude;

  final String? webLink; //Nullable
  final String? facebookLink; //Nullable
  final String? twitterLink; //Nullable
  final String? instagramLink; //Nullable

  Club(
    this.clubID,
    this.name,
    this.averageRating,
    this.address,
    this.phoneNumber,
    this.clubPromotions,
    this.upcomingEvents,
    this.images,
    this.moments,
    this.reviews,
    this.userReview,
    this.totalReviews,
    this.latitude,
    this.longitude,
    this.webLink,
    this.facebookLink,
    this.twitterLink,
    this.instagramLink,
  );

  factory Club.fromJson(dynamic json, bool isListString) {
    return Club(
      json['clubID'],
      json['name'],
      json['averageRating'],
      json['address'],
      json['phoneNumber'],
      (isListString ? (jsonDecode(json['clubPromotions']) as List?) : (json['clubPromotions']) as List?)!
            .map((e) => ClubPromotion.fromJson(e))
            .toList(),
      (isListString ? (jsonDecode(json['upcomingEvents']) as List?) : (json['upcomingEvents']) as List?)!
            .map((e) => Event.fromJson(e))
            .toList(),
      (isListString ? (jsonDecode(json['images']) as List?) : (json['images']) as List?)!
            .map((e) => e.toString())
            .toList(),
      (isListString ? (jsonDecode(json['moments']) as List?) : (json['moments']) as List?)!
            .map((e) => SocialPost.fromJson(e))
            .toList(),
      (isListString ? (jsonDecode(json['reviews']) as List?) : (json['reviews']) as List?)!
            .map((e) => ClubReview.fromJson(e))
            .toList(),
      json['userReview'] == null ? null : ClubReview.fromJson(json['userReview']),
      json['totalReviews'],
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
      "clubPromotions": jsonEncode(clubPromotions),
      "upcomingEvents": jsonEncode(upcomingEvents),
      "images": jsonEncode(images),
      "moments": jsonEncode(moments),
      "reviews": jsonEncode(reviews),
      "userReview": userReview == null ? null : userReview!.toJson(),
      "latitude": latitude,
      "totalReviews": totalReviews,
      "longitude": longitude,
      "webLink": webLink,
      "facebookLink": facebookLink,
      "twitterLink": twitterLink,      
      "instagramLink": instagramLink,      
    };
  }
}
