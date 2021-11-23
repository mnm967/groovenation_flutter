class Event {
  final String? eventID;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? clubID;
  final String? clubName;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final bool? isAdultOnly;

  final String? webLink;
  final String? facebookLink;
  final String? twitterLink;
  final String? instagramLink;
  final bool? hasTickets;

  Event(
    this.eventID,
    this.title,
    this.description,
    this.imageUrl,
    this.clubID,
    this.clubName,
    this.eventStartDate,
    this.eventEndDate,
    this.isAdultOnly,
    this.webLink,
    this.facebookLink,
    this.twitterLink,
    this.instagramLink,
    this.hasTickets,
  );

  factory Event.fromJson(dynamic json) {
    return Event(
      json['eventID'],
      json['title'],
      json['description'],
      json['imageUrl'],
      json['clubID'],
      json['clubName'],
      DateTime.parse(json['eventStartDate']),
      DateTime.parse(json['eventEndDate']),
      json['isAdultOnly'],
      json['webLink'],
      json['facebookLink'],
      json['twitterLink'],
      json['instagramLink'],
      json['hasTickets'],
    );
  }

  Map toJson() => {
        "eventID": eventID,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "clubID": clubID,
        "clubName": clubName,
        "eventStartDate": eventStartDate.toIso8601String(),
        "eventEndDate": eventEndDate.toIso8601String(),
        "isAdultOnly": isAdultOnly,
        "webLink": webLink,
        "facebookLink": facebookLink,
        "twitterLink": twitterLink,
        "instagramLink": instagramLink,
        "hasTickets": hasTickets,
      };
}
