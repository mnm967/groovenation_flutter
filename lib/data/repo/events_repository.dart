import 'package:groovenation_flutter/models/event.dart';

class EventsRepository {
  Future<List<Event>> getTestEvents(int page) async {
    Event e = new Event(
        "jdkvbdnfgddsaogrkdfgdh",
        "Helix After Party",
        "A fire after party.",
        "http",
        "gyvygv9876tfvghbj",
        "Club Groovana",
        DateTime.now(),
        DateTime.now().add(Duration(hours: 7)),
        true,
        null,
        null,
        null,
        null);
    
    Event e1 = new Event(
        "jdkvbdnfgdghfogrkdfgdh",
        "Jive After Party",
        "A fire after party.",
        "http",
        "gyvygv9876tfvghbj",
        "Club Groovana",
        DateTime.now(),
        DateTime.now().add(Duration(hours: 7)),
        true,
        null,
        null,
        null,
        null);
    
    Event e2 = new Event(
        "jdkvbdnfgdogrurtkdfgdh",
        "Groova After Party",
        "A fire after party.",
        "http",
        "gyvygv9876tfvghbj",
        "Club Groovana",
        DateTime.now(),
        DateTime.now().add(Duration(hours: 7)),
        true,
        null,
        null,
        null,
        null);

    await Future.delayed(const Duration(seconds: 3), () => "4");

    return [e1, e2, e2, e, e, e2];
  }

  Future<List<Event>> getFavouriteEvents(int page) async {
    return [];
  }

  Future<List<Event>> getUpcomingEvents(int page) async {
    return [];
  }
}
