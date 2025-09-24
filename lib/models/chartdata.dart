import 'dart:convert';

List<ChartData> chartDataFromJson(String str) =>
    List<ChartData>.from(json.decode(str).map((x) => ChartData.fromJson(x)));

class ChartData {
  ChartData({required this.elName, required this.elCount});

  final String elName;
  final int elCount;

  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
        elName: json["elName"],
        elCount: json["elCount"],
      );
}
