// To parse this JSON data, do
//
//     final params = paramsFromJson(jsonString);

import 'dart:convert';

Params paramsFromJson(String str) => Params.fromJson(json.decode(str));

String paramsToJson(Params data) => json.encode(data.toJson());

class Params {
  String companyName;
  String chiefAccountant;
  String assistantAccountant;
  String googleApiKey;
  String countingItemsOrderBy;

  Params({
    required this.companyName,
    this.chiefAccountant = '',
    this.assistantAccountant = '',
    this.googleApiKey = '',
    this.countingItemsOrderBy = 'code',
  });

  factory Params.fromJson(Map<String, dynamic> json) => Params(
    companyName: json['companyName'],
    chiefAccountant: json['chiefAccountant'] ?? '',
    assistantAccountant: json['assistantAccountant'] ?? '',
    googleApiKey: json['googleApiKey'] ?? '',
    countingItemsOrderBy: json['countingItemsOrderBy'] ?? '0',
  );

  Map<String, dynamic> toJson() => {
    "companyName": companyName,
    "chiefAccountant": chiefAccountant,
    "assistantAccountant": assistantAccountant,
    "googleApiKey": googleApiKey,
    "countingItemsOrderBy": countingItemsOrderBy,
  };
}
