class Ticket {
  final String ticketID;
  final String eventID;
  final String eventName;
  final String clubName;
  final double clubLatitude;
  final double clubLongitude;
  final DateTime startDate;
  final DateTime endDate;
  final String ticketType;
  final int noOfPeople;
  final int totalCost;
  final String encryptedQRTag;
  final bool isScanned;

  Ticket(
    this.ticketID, 
    this.eventID, 
    this.eventName, 
    this.clubName, 
    this.clubLatitude, 
    this.clubLongitude, 
    this.startDate, 
    this.endDate, 
    this.ticketType, 
    this.noOfPeople, 
    this.totalCost, 
    this.encryptedQRTag, 
    this.isScanned
  );

  factory Ticket.fromJson(dynamic json) {
    return Ticket(
      json['ticketID'],
      json['eventID'],
      json['eventName'],
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
      "clubName": clubName,  
      "clubLatitude": clubLatitude,  
      "clubLongitude": clubLongitude,  
      "startDate": startDate.toIso8601String(),  
      "endDate": endDate.toIso8601String(),  
      "ticketType": ticketType,  
      "noOfPeople": noOfPeople,  
      "totalCost": totalCost,  
      "encryptedQRTag": encryptedQRTag,  
      "isScanned": isScanned,  
    };
  }
}
