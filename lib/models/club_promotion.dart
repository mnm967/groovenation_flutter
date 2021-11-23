class ClubPromotion {
  final String? promotionID;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? clubID;
  final DateTime promotionStartDate;
  final DateTime promotionEndDate;

  ClubPromotion(
    this.promotionID,
    this.title,
    this.description,
    this.imageUrl,
    this.clubID,
    this.promotionStartDate,
    this.promotionEndDate,
  );

  factory ClubPromotion.fromJson(dynamic json) {
    return ClubPromotion(
      json['promotionID'],
      json['title'],
      json['description'],
      json['imageUrl'],
      json['clubID'],
      DateTime.parse(json['promotionStartDate']),
      DateTime.parse(json['promotionEndDate']),
    );
  }

  Map toJson() => {
        "promotionID": promotionID,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "clubID": clubID,
        "promotionStartDate": promotionStartDate.toIso8601String(),
        "promotionEndDate": promotionEndDate.toIso8601String(),
      };
}
