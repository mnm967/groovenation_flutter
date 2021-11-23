import 'package:hive/hive.dart';

part 'ticket.g.dart';

@HiveType(typeId: 8)

class Ticket {
  @HiveField(0)
  final String? ticketID;

  @HiveField(1)
  final String? eventID;

  @HiveField(2)
  final String? eventName;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final String? clubName;

  @HiveField(5)
  final double? clubLatitude;

  @HiveField(6)
  final double? clubLongitude;

  @HiveField(7)
  final DateTime? startDate;

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final String? ticketType;

  @HiveField(10)
  final int? noOfPeople;

  @HiveField(11)
  final int? totalCost;

  @HiveField(12)
  final String? encryptedQRTag;

  @HiveField(13)
  final bool? isScanned;

  Ticket(
      this.ticketID,
      this.eventID,
      this.eventName,
      this.imageUrl,
      this.clubName,
      this.clubLatitude,
      this.clubLongitude,
      this.startDate,
      this.endDate,
      this.ticketType,
      this.noOfPeople,
      this.totalCost,
      this.encryptedQRTag,
      this.isScanned);

  factory Ticket.fromJson(dynamic json) {
    return Ticket(
      json['ticketID'],
      json['eventID'],
      json['eventName'],
      json['imageUrl'],
      json['clubName'],
      json['clubLatitude'],
      json['clubLongitude'],
      DateTime.parse(json['startDate']),
      DateTime.parse(json['endDate']),
      json['ticketType'],
      json['noOfPeople'],
      json['totalCost'],
      json['encryptedQRTag'],
      json['isScanned'],
    );
  }

  Map toJson() {
    return {
      "ticketID": ticketID,
      "eventID": eventID,
      "eventName": eventName,
      "imageUrl": imageUrl,
      "clubName": clubName,
      "clubLatitude": clubLatitude,
      "clubLongitude": clubLongitude,
      "startDate": startDate!.toIso8601String(),
      "endDate": endDate!.toIso8601String(),
      "ticketType": ticketType,
      "noOfPeople": noOfPeople,
      "totalCost": totalCost,
      "encryptedQRTag": encryptedQRTag,
      "isScanned": isScanned,
    };
  }
}
