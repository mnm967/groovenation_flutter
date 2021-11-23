class TicketPrice {
  final String? ticketType;
  final int? price;
  final int? numAvailable;

  TicketPrice(this.ticketType, this.price, this.numAvailable);

  factory TicketPrice.fromJson(dynamic json) {
    return TicketPrice(json['ticketType'], json['ticketPrice'], json['numTicketsAvailable']);
  }
}