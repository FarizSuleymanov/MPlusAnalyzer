import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mplusanalyzer/models/counting_item.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/pages/items/items_page.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/card_choose.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/keypad.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import 'package:uuid/uuid.dart';

class CountingDoc extends StatefulWidget {
  final dynamic countingData;
  const CountingDoc(this.countingData, {Key? key}) : super(key: key);

  @override
  State<CountingDoc> createState() => _CountingDocState();
}

class _CountingDocState extends State<CountingDoc> {
  LanguagePack lan = LanguagePack();
  bool isLoading = true, isItemsLoading = false, isNew = true;
  DocumentItems documentItems = DocumentItems(
    warehouse: Warehouse(whId: 0, whCode: '', whName: ''),
  );
  bool isCarChoosen = false;
  List<Warehouse> listWarehouses = [];
  List<CountingItem> listItems = [];
  TextEditingController txtSeller = TextEditingController(),
      txtChief = TextEditingController();
  bool isSearching = false;
  TextEditingController txtSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String cntGuid = '';

  Future<void> onCarTap() async {
    List<String> listCards = listWarehouses
        .map((e) => '${e.whCode} - ${e.whName}')
        .toList();
    if (listCards.isNotEmpty) {
      await CardChoose(context).showCardModalBottomSheet(listCards, (i) {
        documentItems.warehouse = listWarehouses[i];
      });
      if (documentItems.warehouse.whId == 0) {
        Messages(
          context: context,
        ).showSnackBar(lan.getTranslatedText('chooseCar'), 0);
        return;
      }
      isCarChoosen = true;
      setItemsOnCar();
    }
  }

  void fillElements() async {
    Map body = {"userGuid": GlobalParams.userParams.userUID};
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Users/GetWarehouses',
      body,
    );
    if (response.code == 200) {
      List<dynamic> data = jsonDecode(response.message) as List;
      data.forEach((e) {
        if (e['selected'] == true)
          listWarehouses.add(
            Warehouse(whId: e['whId'], whCode: e['whNo'], whName: e['whName']),
          );
      });
    }

    if (widget.countingData != null) {
      isNew = false;
      cntGuid = widget.countingData['cntGuid'];
      documentItems.warehouse = Warehouse(
        whId: widget.countingData['cntWarehouseId'],
        whCode: widget.countingData['cntWarehouseCode'],
        whName: widget.countingData['cntWarehouseName'],
      );
      isCarChoosen = true;

      txtSeller.text = widget.countingData['cntSeller'];
      txtChief.text = widget.countingData['cntChief'];

      // Fetching existing counting items
      Map body = {"cntGuid": widget.countingData['cntGuid']};
      HttpResponseModel response = await API().request_(
        context,
        'POST',
        'Countings/GetCountingsDocLines',
        body,
      );
      if (response.code == 200) {
        List<dynamic> data = jsonDecode(response.message) as List;
        listItems.clear();
        data.forEach((e) {
          listItems.add(
            CountingItem(
              itemCode: e['itemCode'],
              itemName: e['itemName'],
              quantityOnCar: double.tryParse(e['qntOnCar'].toString()) ?? 0,
              quantityTyped1: double.tryParse(e['qntTyped1'].toString()) ?? 0,
              quantityTyped2: double.tryParse(e['qntTyped2'].toString()) ?? 0,
              quantityTyped3: double.tryParse(e['qntTyped3'].toString()) ?? 0,
              quantityTyped4: double.tryParse(e['qntTyped4'].toString()) ?? 0,
              quantityTyped5: double.tryParse(e['qntTyped5'].toString()) ?? 0,
            ),
          );
        });
      }
    } else {
      isNew = true;
      const uuid = Uuid();
      cntGuid = uuid.v4();
    }
    setState(() {
      isLoading = false;
    });
  }

  String getHeaderText() {
    if (widget.countingData != null) {
      return '${widget.countingData['cntDocNumber']}';
    } else {
      return lan.getTranslatedText('newCounting');
    }
  }

  save() async {
    String msgKey = '';

    if (documentItems.warehouse.whId == 0) {
      msgKey = 'warehouseNotSelected';
    } else if (listItems.isEmpty) {
      msgKey = 'noItemsOnlist';
    }

    if (msgKey != '') {
      Messages(context: context).showSnackBar(lan.getTranslatedText(msgKey), 0);
      return;
    }

    Messages(context: context).showYesNoDialog(
      lan.getTranslatedText('areYouSureYouWantToSave'),
      () async {
        try {
          Map body = {
            "cntGuid": cntGuid,
            "warehouseId": documentItems.warehouse.whId,
            "cntSeller": txtSeller.text,
            "cntChief": txtChief.text,
            "isNew": isNew,
            "items": listItems.map((e) {
              return {
                "itemCode": e.itemCode,
                "qntOnCar": e.quantityOnCar,
                "qntTyped1": e.quantityTyped1,
                "qntTyped2": e.quantityTyped2,
                "qntTyped3": e.quantityTyped3,
                "qntTyped4": e.quantityTyped4,
                "qntTyped5": e.quantityTyped5,
              };
            }).toList(),
          };
          HttpResponseModel response = await API().request_(
            context,
            'POST',
            'Countings/SaveCounting',
            body,
          );

          if (response.code == 200) {
            Messages(
              context: context,
            ).showSnackBar(lan.getTranslatedText('documentSaved'), 1);
            Navigator.pop(context);
          }

          setState(() {});
        } catch (e) {
          Messages(
            context: context,
          ).showWarningDialog(lan.getTranslatedText('anErrorOccurred'));
        }
      },
    );
  }

  Future<void> setItemsOnCar() async {
    setState(() {
      isItemsLoading = true;
    });
    Map body = {"warehouseId": documentItems.warehouse.whId};
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Countings/GetCountingItemsOnCar',
      body,
    );
    if (response.code == 200) {
      List<dynamic> data = jsonDecode(response.message) as List;
      listItems.clear();
      data.forEach((e) {
        listItems.add(
          CountingItem(
            itemCode: e['itemCode'],
            itemName: e['itemName'],
            quantityOnCar: double.tryParse(e['onCar'].toString()) ?? 0,
            quantityTyped1: 0,
            quantityTyped2: 0,
            quantityTyped3: 0,
            quantityTyped4: 0,
            quantityTyped5: 0,
          ),
        );
      });
    }
    setState(() {
      isItemsLoading = false;
    });
  }

  void _onSearchChanged(String filterKey_) {
    if (filterKey_.isNotEmpty) {
      for (int i = 0; i < listItems.length; i++) {
        final filter = filterKey_.toLowerCase();
        if (listItems[i].itemCode.toLowerCase().contains(filter) ||
            listItems[i].itemName.toLowerCase().contains(filter)) {
          Utils().scrollToIndex(_scrollController, i);
          break;
        }
      }
    } else {
      Utils().scrollToIndex(_scrollController, 0);
    }
  }

  @override
  void initState() {
    fillElements();
    super.initState();
  }

  Widget getWidgetItemCard(CountingItem item) {
    return GestureDetector(
      onTap: () async {
        await KeyPad().showItemCountingKeyPadDialog(context, item);
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: Offset(2, 4), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(22),
          color: item.quantityTypedTotal > 0
              ? ThemeModule.cLightGreenColor
              : ThemeModule.cWhiteBlackColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                item.itemName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'poppins_semibold',
                  fontSize: 12,
                  color: ThemeModule.cBlackWhiteColor,
                ),
              ),
            ),

            Widgets().getRichText(
              lan.getTranslatedText('code'),
              TextStyle(
                color: ThemeModule.cBlackWhiteColor,
                fontFamily: 'poppins_regular',
                fontSize: 12,
              ),
              item.itemCode,
              TextStyle(
                color: ThemeModule.cBlackWhiteColor,
                fontSize: 12,
                fontFamily: 'poppins_semibold',
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lan.getTranslatedText('onSystem'),
                        style: TextStyle(
                          fontFamily: 'poppins_regular',
                          fontSize: 12,
                          color: ThemeModule.cBlackWhiteColor,
                        ),
                      ),
                      SizedBox(width: 5),
                      GlobalParams.userParams.countingStockVisibility == 1
                          ? Text(
                              item.quantityOnCar.toStringAsFixed(2),
                              style: TextStyle(
                                fontFamily: 'poppins_semibold',
                                fontSize: 12,
                                color: ThemeModule.cBlackWhiteColor,
                              ),
                            )
                          : Icon(
                              Icons.visibility_off,
                              color: Colors.grey,
                              size: 15,
                            ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lan.getTranslatedText('totalCounted'),
                        style: TextStyle(
                          fontFamily: 'poppins_regular',
                          fontSize: 12,
                          color: ThemeModule.cBlackWhiteColor,
                        ),
                      ),
                      SizedBox(width: 5),

                      Text(
                        item.quantityTypedTotal.toStringAsFixed(2),
                        style: TextStyle(
                          fontFamily: 'poppins_semibold',
                          fontSize: 12,
                          color: ThemeModule.cBlackWhiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              lan.getTranslatedText('quantityTyped'),
              style: TextStyle(
                fontFamily: 'poppins_regular',
                fontSize: 12,
                color: ThemeModule.cBlackWhiteColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                getTypedQuantityWidget(item.quantityTyped1),
                SizedBox(width: 5),
                getTypedQuantityWidget(item.quantityTyped2),
                SizedBox(width: 5),
                getTypedQuantityWidget(item.quantityTyped3),
                SizedBox(width: 5),
                getTypedQuantityWidget(item.quantityTyped4),
                SizedBox(width: 5),
                getTypedQuantityWidget(item.quantityTyped5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemListWidget() {
    return isItemsLoading
        ? Widgets().getLoadingWidget(context)
        : ListView.builder(
            controller: _scrollController,
            itemExtent: 105,
            itemCount: listItems.length + 1,
            itemBuilder: (context, index) {
              if (index == listItems.length) {
                return SizedBox(height: 60);
              }
              CountingItem item = listItems[index];
              return getWidgetItemCard(item);
            },
          );
  }

  Widget getTypedQuantityWidget(double quantity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(color: ThemeModule.cForeColor),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          quantity.toStringAsFixed(2),
          style: TextStyle(
            color: Colors.red,
            fontFamily: 'poppins_semibold',
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (documentItems.warehouse.whId == 0) {
            Messages(
              context: context,
            ).showSnackBar(lan.getTranslatedText('warehouseNotSelected'), 0);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemsPage()),
          ).then((value) {
            if (value != null && value is CountingItem) {
              bool isItemExists = listItems
                  .where((e) => e.itemCode == value.itemCode)
                  .isNotEmpty;
              if (!isItemExists) {
                listItems.add(value);
              }
              setState(() {});
            }
          });
        },
        child: Icon(Icons.add, size: 32, color: Colors.white),
        backgroundColor: ThemeModule.cForeColor,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              GestureDetector(
                onTap: () => setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    txtSearchController.clear();
                    _onSearchChanged('');
                  }
                }),
                child: Container(
                  height: 36,
                  width: 36,
                  child: Icon(
                    size: 24,
                    isSearching ? Icons.close : Icons.search,
                    color: ThemeModule.cBlackWhiteColor,
                  ),
                ),
              ),
              SizedBox(width: 7),
              GestureDetector(
                onTap: () => save(),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ThemeModule.cWhiteBlackColor,
                  ),
                  child: Icon(
                    size: 24,
                    Icons.save,
                    color: ThemeModule.cForeColor,
                  ),
                ),
              ),
              SizedBox(width: 7),
            ],
            title: !isSearching
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ThemeModule.cWhiteBlackColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 2,
                        ),
                        child: Text(
                          getHeaderText(),
                          style: TextStyle(
                            fontFamily: 'poppins_medium',
                            fontSize: 20,
                            color: ThemeModule.cBlackWhiteColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : Widgets().getSearchBar(
                    context,
                    txtSearchController,
                    () => _onSearchChanged(txtSearchController.text),
                  ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: !isLoading
              ? Column(
                  children: [
                    Widgets().getInvoiceChooseCardWidget(
                      context,
                      '${documentItems.warehouse.whCode} - ${documentItems.warehouse.whName}',
                      'car',
                      'chooseCar',
                      Icons.local_shipping,
                      isCarChoosen,
                      () => onCarTap(),
                    ), //Client
                    SizedBox(height: 5),
                    Widgets().getTextFormField(
                      txtSeller,
                      (v) {},
                      [LengthLimitingTextInputFormatter(100)],
                      'seller',
                      ThemeModule.cTextFieldLabelColor,
                      ThemeModule.cTextFieldFillColor,
                      false,
                      TextInputType.text,
                    ),
                    SizedBox(height: 5),
                    Widgets().getTextFormField(
                      txtChief,
                      (v) {},
                      [LengthLimitingTextInputFormatter(100)],
                      'chief',
                      ThemeModule.cTextFieldLabelColor,
                      ThemeModule.cTextFieldFillColor,
                      false,
                      TextInputType.text,
                    ),

                    const Divider(height: 10, thickness: 1),
                    Expanded(child: getItemListWidget()),
                  ],
                )
              : Widgets().getLoadingWidget(context),
        ),
      ),
    );
  }
}
