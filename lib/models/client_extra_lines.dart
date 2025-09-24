// To parse this JSON data, do
//
//     final clientExtraLines = clientExtraLinesFromJson(jsonString);

import 'dart:convert';

List<ClientExtraLines> clientExtraLinesFromJson(String str) =>
    List<ClientExtraLines>.from(
      json.decode(str).map((x) => ClientExtraLines.fromJson(x)),
    );

String clientExtraLinesToJson(List<ClientExtraLines> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientExtraLines {
  String itemCode;
  String itemName;
  double amount;
  double price;
  double discount;
  int vat;

  ClientExtraLines({
    required this.itemCode,
    required this.itemName,
    required this.amount,
    required this.price,
    required this.discount,
    required this.vat,
  });

  factory ClientExtraLines.fromJson(Map<String, dynamic> json) =>
      ClientExtraLines(
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        amount: json["amount"]?.toDouble(),
        price: json["price"]?.toDouble(),
        discount: json["discount"]?.toDouble(),
        vat: json["vat"],
      );

  Map<String, dynamic> toJson() => {
    "ItemCode": itemCode,
    "ItemName": itemName,
    "Amount": amount,
    "Price": price,
    "Discount": discount,
    "Vat": vat,
  };
}
