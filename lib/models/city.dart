class City {
  final String? cityID;
  final String? name;
  final String? imageUrl;
  final double? defaultLat;
  final double? defaultLon;

  City(this.cityID, this.name, this.imageUrl, this.defaultLat, this.defaultLon);

  factory City.fromJson(dynamic json) {
    return City(
      json['id'],
      json['name'],
      json['image_url'],
      json['default_lat'],
      json['default_lon'],
    );
  }
}