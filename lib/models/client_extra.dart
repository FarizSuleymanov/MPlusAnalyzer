// To parse this JSON data, do
//
//     final clientExtra = clientExtraFromJson(jsonString);

import 'dart:convert';

List<ClientExtra> clientExtraFromJson(String str) => List<ClientExtra>.from(
    json.decode(str).map((x) => ClientExtra.fromJson(x)));

String clientExtraToJson(List<ClientExtra> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientExtra {
  String date;
  int type;
  double total;
  String invoiceNumber;
  double? lineDebt;
  String id;

  ClientExtra({
    required this.date,
    required this.type,
    required this.total,
    required this.invoiceNumber,
    this.lineDebt,
    required this.id,
  });

  factory ClientExtra.fromJson(Map<String, dynamic> json) => ClientExtra(
        date: json["date"],
        type: json["type"],
        total: json["total"]?.toDouble(),
        invoiceNumber: json["invoiceNumber"],
        lineDebt: 0,
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "type": type,
        "total": total,
        "invoiceNumber": invoiceNumber,
        "lineDebt": 0,
        "id": id,
      };
}
