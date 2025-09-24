import 'package:flutter/material.dart';
import 'package:mplusanalyzer/models/benchmark_item.dart';
import 'package:mplusanalyzer/models/counting_item.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';

class KeyPad {
  final LanguagePack lan = LanguagePack();
  int selectedCountingForEdit = 1;

  String getAmountString(String oldAmount, String label) {
    switch (label) {
      case 'C':
      case '\\':
        return '0';
      case '.':
        return oldAmount.contains('.') ? oldAmount : '$oldAmount.';
      default:
        if (double.tryParse(oldAmount) == 0 && !oldAmount.startsWith('0.')) {
          return label;
        }
        return oldAmount + (int.tryParse(label) ?? '').toString();
    }
  }

  String getLastTwoCharacters(String input) =>
      input.length < 2 ? input : input.substring(input.length - 2);

  String getDoubleString(double value) {
    final str = value.toString();
    return str.endsWith('.0') ? str.substring(0, str.length - 2) : str;
  }

  Widget getLabelKeyWidget(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: ThemeModule.cForeColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'poppins_regular',
                fontSize: 30,
                color: ThemeModule.cWhiteBlackColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getIconKeyWidget(BuildContext context, IconData icon) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: ThemeModule.cForeColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Icon(icon, size: 30, color: ThemeModule.cWhiteBlackColor),
      ),
    );
  }

  Widget getCountingWidget(
    BuildContext context,
    StateSetter setState,
    Map<int, String> countings,
    int countingNumber, {
    String? label,
  }) {
    final isSelected = selectedCountingForEdit == countingNumber;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCountingForEdit = countingNumber),
        child: Column(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isSelected ? Colors.red : ThemeModule.cForeColor,
                ),
              ),
              child: Center(
                child: Text(
                  countings[countingNumber]!,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.red
                        : ThemeModule.cBlackWhiteColor,
                    fontFamily: 'poppins_semibold',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2),
            Center(
              child: Text(
                label ??
                    '${lan.getTranslatedText('counting_')} $countingNumber',
                style: TextStyle(fontFamily: 'poppins_regular', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showItemCountingKeyPadDialog(
    BuildContext context,
    CountingItem itemData,
  ) async {
    Map<int, String> countings = {
      1: getDoubleString(itemData.quantityTyped1),
      2: getDoubleString(itemData.quantityTyped2),
      3: getDoubleString(itemData.quantityTyped3),
      4: getDoubleString(itemData.quantityTyped4),
      5: getDoubleString(itemData.quantityTyped5),
    };

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) {
              void updateCounting(String label) {
                countings[selectedCountingForEdit] = getAmountString(
                  countings[selectedCountingForEdit]!,
                  label,
                );
                setState(() {});
              }

              void handleBackspace() {
                String value = countings[selectedCountingForEdit]!;
                int deleteCount = (value.endsWith('.0') && value.length > 1)
                    ? 2
                    : 1;
                value = value.substring(0, value.length - deleteCount);
                countings[selectedCountingForEdit] = value.isEmpty
                    ? '0'
                    : value;
                setState(() {});
              }

              void handleDone() {
                itemData.quantityTyped1 = double.tryParse(countings[1]!) ?? 0;
                itemData.quantityTyped2 = double.tryParse(countings[2]!) ?? 0;
                itemData.quantityTyped3 = double.tryParse(countings[3]!) ?? 0;
                itemData.quantityTyped4 = double.tryParse(countings[4]!) ?? 0;
                itemData.quantityTyped5 = double.tryParse(countings[5]!) ?? 0;
                Navigator.pop(context);
              }

              return SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: ThemeModule.cForeColor,
                        borderRadius: BorderRadius.circular(39),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            itemData.itemName,
                            style: TextStyle(
                              color: ThemeModule.cWhiteBlackColor,
                              fontFamily: 'poppins_semibold',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        getCountingWidget(context, setState, countings, 1),
                        SizedBox(width: 5),
                        getCountingWidget(context, setState, countings, 2),
                        SizedBox(width: 5),
                        getCountingWidget(context, setState, countings, 3),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        getCountingWidget(context, setState, countings, 4),
                        SizedBox(width: 5),
                        getCountingWidget(context, setState, countings, 5),
                        SizedBox(width: 5),
                        Expanded(child: Container()),
                      ],
                    ),
                    SizedBox(height: 15),
                    ...[
                      ['7', '', '8', '', '9'],
                      ['4', '', '5', '', '6'],
                      ['1', '', '2', '', '3'],
                      ['.', '', '0', '', 'backspace'],
                    ].map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: row.map<Widget>((label) {
                            switch (label) {
                              case '':
                                return SizedBox(width: 5);
                              case 'backspace':
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: handleBackspace,
                                    child: getIconKeyWidget(
                                      context,
                                      Icons.backspace_outlined,
                                    ),
                                  ),
                                );
                              default:
                            }
                            if (label == 'backspace') {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: handleBackspace,
                                  child: getIconKeyWidget(
                                    context,
                                    Icons.backspace_outlined,
                                  ),
                                ),
                              );
                            }
                            return getLabelKeyWidget(
                              context,
                              label,
                              () => updateCounting(label),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        getLabelKeyWidget(
                          context,
                          '\\',
                          () => updateCounting('\\'),
                        ),
                        SizedBox(width: 5),
                        getLabelKeyWidget(
                          context,
                          'C',
                          () => updateCounting('C'),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            onTap: handleDone,
                            child: getIconKeyWidget(context, Icons.done),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> showItemBenchmarkKeyPadDialog(
    BuildContext context,
    BenchmarkItem itemData,
  ) async {
    Map<int, String> countings = {
      1: getDoubleString(itemData.standPrice),
      2: getDoubleString(itemData.actionPrice),
      3: getDoubleString(itemData.weight),
      4: getDoubleString(itemData.listPrice),
    };

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) {
              void updateCounting(String label) {
                countings[selectedCountingForEdit] = getAmountString(
                  countings[selectedCountingForEdit]!,
                  label,
                );
                setState(() {});
              }

              void handleBackspace() {
                String value = countings[selectedCountingForEdit]!;
                int deleteCount = (value.endsWith('.0') && value.length > 1)
                    ? 2
                    : 1;
                value = value.substring(0, value.length - deleteCount);
                countings[selectedCountingForEdit] = value.isEmpty
                    ? '0'
                    : value;
                setState(() {});
              }

              void handleDone() {
                itemData.standPrice = double.tryParse(countings[1]!) ?? 0;
                itemData.actionPrice = double.tryParse(countings[2]!) ?? 0;
                itemData.weight = double.tryParse(countings[3]!) ?? 0;
                itemData.listPrice = double.tryParse(countings[4]!) ?? 0;
                Navigator.pop(context);
              }

              return SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: ThemeModule.cForeColor,
                        borderRadius: BorderRadius.circular(39),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            itemData.itemName,
                            style: TextStyle(
                              color: ThemeModule.cWhiteBlackColor,
                              fontFamily: 'poppins_semibold',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        getCountingWidget(
                          context,
                          setState,
                          countings,
                          1,
                          label: lan.getTranslatedText('standPrice'),
                        ),
                        SizedBox(width: 5),
                        getCountingWidget(
                          context,
                          setState,
                          countings,
                          2,
                          label: lan.getTranslatedText('actionPrice'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        getCountingWidget(
                          context,
                          setState,
                          countings,
                          3,
                          label: lan.getTranslatedText('weight'),
                        ),
                        SizedBox(width: 5),
                        getCountingWidget(
                          context,
                          setState,
                          countings,
                          4,
                          label: lan.getTranslatedText('listPrice'),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),
                    ...[
                      ['7', '', '8', '', '9'],
                      ['4', '', '5', '', '6'],
                      ['1', '', '2', '', '3'],
                      ['.', '', '0', '', 'backspace'],
                    ].map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: row.map<Widget>((label) {
                            switch (label) {
                              case '':
                                return SizedBox(width: 5);
                              case 'backspace':
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: handleBackspace,
                                    child: getIconKeyWidget(
                                      context,
                                      Icons.backspace_outlined,
                                    ),
                                  ),
                                );
                              default:
                            }
                            if (label == 'backspace') {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: handleBackspace,
                                  child: getIconKeyWidget(
                                    context,
                                    Icons.backspace_outlined,
                                  ),
                                ),
                              );
                            }
                            return getLabelKeyWidget(
                              context,
                              label,
                              () => updateCounting(label),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        getLabelKeyWidget(
                          context,
                          '\\',
                          () => updateCounting('\\'),
                        ),
                        SizedBox(width: 5),
                        getLabelKeyWidget(
                          context,
                          'C',
                          () => updateCounting('C'),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            onTap: handleDone,
                            child: getIconKeyWidget(context, Icons.done),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
