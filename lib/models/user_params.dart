class UserParams {
  late final String userToken;
  late final String userUID;
  late final String userFullName;
  late final String userCompanyName;
  late final int confrontMod;
  late final int benchmarkMod;
  late final int countingMod;
  late final int faqMod;
  late final int countingStockVisibility;

  UserParams({
    required this.userToken,
    required this.userUID,
    required this.userFullName,
    required this.userCompanyName,
    required this.confrontMod,
    required this.benchmarkMod,
    required this.countingMod,
    required this.faqMod,
    this.countingStockVisibility = 0,
  });

  factory UserParams.fromJson(Map<String, dynamic> json) => UserParams(
    userToken: json["userToken"],
    userUID: json["userUID"],
    userCompanyName: json["userCompanyName"],
    userFullName: json["userFullName"],
    confrontMod: json["confrontMod"],
    benchmarkMod: json["benchmarkMod"],
    countingMod: json["countingMod"],
    faqMod: json["faqMod"],
    countingStockVisibility: json["countingStockVisibility"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "userToken": userToken,
    "userUID": userUID,
    "userCompanyName": userCompanyName,
    "userFullName": userFullName,
    "confrontMod": confrontMod,
    "benchmarkMod": benchmarkMod,
    "countingMod": countingMod,
    "faqMod": faqMod,
    "countingStockVisibility": countingStockVisibility,
  };
}
