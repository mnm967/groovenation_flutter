import 'package:groovenation_flutter/models/club.dart';

class ClubsRepository {
  Future<List<Club>> getTestClubs(int page) async {
    Club c = new Club("gyvygv9876tfvghbj", "Club Groovana", 4.0, "Hello", "World",
        false, [], [], [], [], null, -1, -1, null, null, null, null);
    
    Club c2 = new Club("gyvymv9876tfvgffbj", "Jive Lounge", 4.0, "Hello", "World",
        false, [], [], [], [], null, -1, -1, null, null, null, null);
    
    Club c3 = new Club("gyvymv9876tfjngffbj", "The Crux", 4.0, "Hello", "World",
        false, [], [], [], [], null, -1, -1, null, null, null, null);

    await Future.delayed(const Duration(seconds: 4), () => "4");

    return [c2, c3, c2, c, c, c3];
  }

  Future<List<Club>> getFavouriteClubs(int page) async {
    return [];
  }

  Future<List<Club>> getTopRatedClubs(int page) async {
    return [];
  }

  Future<List<Club>> getNearbyClubs(int page) async {
    return [];
  }
}
