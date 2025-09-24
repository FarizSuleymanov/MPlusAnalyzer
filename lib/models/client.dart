import 'dart:convert';

List<Client> clientFromJson(String str) =>
    List<Client>.from(json.decode(str).map((x) => Client.fromJson(x)));

String clienToJson(List<Client> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Client {
  late String clientCode;
  late String clientName;
  late String seller;
  late double clientLatitude;
  late double clientLongitude;
  late double clientDebt;
  late String lastConfrontDate;
  late String lastBenchmarkDate;
  late String lastFaqDate;
  late double distance;
  late int statusConfront;
  late int statusFaq;
  late int statusBmk;
  Client({
    required this.clientCode,
    required this.clientName,
    required this.seller,
    required this.clientLatitude,
    required this.clientLongitude,
    required this.clientDebt,
    required this.lastConfrontDate,
    required this.lastBenchmarkDate,
    required this.lastFaqDate,
    required this.distance,
    required this.statusConfront,
    required this.statusFaq,
    required this.statusBmk,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    clientCode: json['clientCode'],
    clientName: json['clientName'],
    seller: json['seller'],
    clientLatitude: json['clientLatitude'].toDouble(),
    clientLongitude: json['clientLongitude'].toDouble(),
    clientDebt: json['clientDebt'].toDouble(),
    lastConfrontDate: json['lastConfrontDate'],
    lastBenchmarkDate: json['lastBenchmarkDate'],
    lastFaqDate: json['lastFaqDate'],
    distance: json['distance'].toDouble(),
    statusConfront: json['statusConfront'],
    statusFaq: json['statusFaq'],
    statusBmk: json['statusBmk'],
  );

  Map<String, dynamic> toJson() {
    return {
      'clientCode': clientCode,
      'clientName': clientName,
      'seller': seller,
      'clientLatitude': clientLatitude,
      'clientLongitude': clientLongitude,
      'clientDebt': clientDebt,
      'lastConfrontDate': lastConfrontDate,
      'lastBenchmarkDate': lastBenchmarkDate,
      'lastFaqDate': lastFaqDate,
      'distance': distance,
      'statusConfront': statusConfront,
      'statusFaq': statusFaq,
      'statusBmk': statusBmk,
    };
  }
}
