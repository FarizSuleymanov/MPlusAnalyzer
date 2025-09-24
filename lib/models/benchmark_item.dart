class BenchmarkItem {
  late String guid;
  late String itemCode;
  late String itemName;
  late String category1;
  late String category2;
  late String firm;
  late double weight;
  late double listPrice;
  late double standPrice;
  late double actionPrice;
  late String comment;

  BenchmarkItem({
    required this.guid,
    required this.itemCode,
    required this.itemName,
    required this.category1,
    required this.category2,
    required this.firm,
    this.weight = 0,
    this.listPrice = 0,
    this.standPrice = 0,
    this.actionPrice = 0,
    this.comment = '',
  });
}
