// To parse this JSON data, do
//
//     final googleDirections = googleDirectionsFromJson(jsonString);

import 'dart:convert';

GoogleDirections googleDirectionsFromJson(String str) =>
    GoogleDirections.fromJson(json.decode(str));

String googleDirectionsToJson(GoogleDirections data) =>
    json.encode(data.toJson());

class GoogleDirections {
  List<Route> routes;
  String status;
  String? error_message;

  GoogleDirections({
    required this.routes,
    required this.status,
    this.error_message = '',
  });

  factory GoogleDirections.fromJson(Map<String, dynamic> json) =>
      GoogleDirections(
        routes: List<Route>.from(json["routes"].map((x) => Route.fromJson(x))),
        status: json["status"],
        error_message: json["error_message"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "routes": List<dynamic>.from(routes.map((x) => x.toJson())),
    "status": status,
  };
}

class Route {
  List<Leg> legs;
  List<int> waypointOrder;

  Route({required this.legs, required this.waypointOrder});

  factory Route.fromJson(Map<String, dynamic> json) => Route(
    legs: List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
    waypointOrder: List<int>.from(json["waypoint_order"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
    "waypoint_order": List<dynamic>.from(waypointOrder.map((x) => x)),
  };
}

class Leg {
  Distance distance;
  Leg({required this.distance});

  factory Leg.fromJson(Map<String, dynamic> json) =>
      Leg(distance: Distance.fromJson(json["distance"]));

  Map<String, dynamic> toJson() => {"distance": distance.toJson()};
}

class Distance {
  String text;
  int value;

  Distance({required this.text, required this.value});

  factory Distance.fromJson(Map<String, dynamic> json) =>
      Distance(text: json["text"], value: json["value"]);

  Map<String, dynamic> toJson() => {"text": text, "value": value};
}
