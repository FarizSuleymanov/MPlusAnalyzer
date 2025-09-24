class CountingItem {
  late String mainGroup;
  late String subGroup;
  late String itemCode;
  late String itemName;
  late double quantityOnCar;
  late double quantityTyped1;
  late double quantityTyped2;
  late double quantityTyped3;
  late double quantityTyped4;
  late double quantityTyped5;

  double get quantityTypedTotal =>
      quantityTyped1 +
      quantityTyped2 +
      quantityTyped3 +
      quantityTyped4 +
      quantityTyped5;

  CountingItem({
    this.mainGroup = '',
    this.subGroup = '',
    required this.itemCode,
    required this.itemName,
    required this.quantityOnCar,
    required this.quantityTyped1,
    required this.quantityTyped2,
    required this.quantityTyped3,
    required this.quantityTyped4,
    required this.quantityTyped5,
  });
}

class Warehouse {
  late int whId;
  String whCode = '';
  String whName = '';
  Warehouse({required this.whId, required this.whCode, required this.whName});
}

class DocumentItems {
  late Warehouse warehouse;
  DocumentItems({required this.warehouse});
}
