import 'dart:convert';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:animated_tree_view/tree_view/widgets/expansion_indicator.dart';
import 'package:animated_tree_view/tree_view/widgets/indent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mplusanalyzer/models/benchmark_item.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:uuid/uuid.dart';
import '../../models/client.dart';
import '../../models/document_items.dart';
import '../../utils/card_choose.dart';
import '../../utils/messages.dart';
import '../../widgets/keypad.dart';
import '../../widgets/tri_state_checkbox.dart';
import '../clients/clients_page.dart';

class BenchmarkDoc extends StatefulWidget {
  final dynamic benchmarkData;
  final List<String> listClientCodesFromDocList;
  const BenchmarkDoc(
    this.benchmarkData,
    this.listClientCodesFromDocList, {
    Key? key,
  }) : super(key: key);

  @override
  State<BenchmarkDoc> createState() => _BenchmarkDocState();
}

class _BenchmarkDocState extends State<BenchmarkDoc> {
  LanguagePack lan = LanguagePack();
  bool isLoading = true, isNew = true;
  List<BenchmarkItem> listItems = [], listAllItems = [];
  bool isSearching = false;
  TextEditingController txtSearchController = TextEditingController(),
      txtDebtFilter = TextEditingController(),
      textClientCategory = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  TreeNode treeNodeMain = TreeNode();
  ExpansibleController clientFilterExpansibleController =
      new ExpansibleController();
  final controllerDaysOfWeekMultiSelect = MultiSelectController<int>();
  LatLng _currentLocation = LatLng(0, 0);
  List<DropdownItem<int>> listDaysOfWeek = [];
  List<String> listFirms = [], listCategories1 = [], listCategories2 = [];
  String selectedFirm = '', selectedCategory1 = '', selectedCategory2 = '';
  DocumentItems documentItems = DocumentItems(
    client: Client(
      clientCode: '',
      clientName: '',
      seller: '',
      clientLatitude: 0,
      clientLongitude: 0,
      clientDebt: 0,
      lastConfrontDate: '',
      lastFaqDate: '',
      lastBenchmarkDate: '',
      distance: 0,
      statusConfront: 0,
      statusFaq: 0,
      statusBmk: 0,
    ),
  );
  String bmkGuid = '';

  fillElements() async {
    _currentLocation = await Utils().getCurrentLocation(context);
    txtDebtFilter.text = '0';
    treeNodeMain = await Utils().getClientFilterTreeNode(context);
    listDaysOfWeek = Utils().getWeekDays();

    if (widget.benchmarkData != null) {
      isNew = false;
      clientFilterExpansibleController.collapse();
      documentItems.client.clientCode = widget.benchmarkData['clientCode'];
      documentItems.client.clientName = widget.benchmarkData['clientName'];

      bmkGuid = widget.benchmarkData['bmkGuid'];

      Map body = {"bmkGuid": bmkGuid, "bmiStatus": 1, "filterConditions": []};
      HttpResponseModel response = await API().request_(
        context,
        'POST',
        'Benchmarks/GetBenchmarkLines',
        body,
      );
      if (response.code == 200) {
        List _list = jsonDecode(response.message) as List;
        listAllItems = _list
            .map(
              (e) => BenchmarkItem(
                guid: e['bmiGuid'],
                itemCode: e['itemCode'],
                itemName: e['itemName'],
                category1: e['category1'],
                category2: e['category2'],
                firm: e['firm'],
                weight: e['weight'].toDouble(),
                listPrice: e['listPrice'].toDouble(),
                standPrice: e['standPrice'].toDouble(),
                actionPrice: e['actionPrice'].toDouble(),
                comment: e['comment'],
              ),
            )
            .toList();
      }
    } else {
      const uuid = Uuid();
      bmkGuid = uuid.v4();
      await fillAllItems();
    }
    listFirms = listAllItems
        .map((e) => e.firm)
        .toSet()
        .toList()
        .map((firm) => firm)
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  String getHeaderText() {
    if (widget.benchmarkData != null) {
      return '${widget.benchmarkData['docNumber']}';
    } else {
      return lan.getTranslatedText('newBenchmark');
    }
  }

  void openCommentDialog(BenchmarkItem item) {
    TextEditingController _txtCommentController = TextEditingController(
      text: item.comment,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lan.getTranslatedText('addComment')),
        content: TextField(
          controller: _txtCommentController,
          maxLines: 1,
          inputFormatters: [LengthLimitingTextInputFormatter(150)],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(lan.getTranslatedText('cancel')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(lan.getTranslatedText('save')),
            onPressed: () {
              setState(() {
                item.comment = _txtCommentController.text;
                listAllItems.forEach((element) {
                  if (element.guid == item.guid) {
                    element.weight = item.weight;
                    element.listPrice = item.listPrice;
                    element.standPrice = item.standPrice;
                    element.actionPrice = item.actionPrice;
                  }
                });
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  save() async {
    String msgKey = '';
    List<BenchmarkItem> typedItems = listAllItems
        .where(
          (e) =>
              e.weight > 0 ||
              e.actionPrice > 0 ||
              e.listPrice > 0 ||
              e.standPrice > 0,
        )
        .toList();
    if (documentItems.client.clientCode == '') {
      msgKey = 'clientNotSelected';
    } else if (typedItems.isEmpty) {
      msgKey = 'noItemsOnList';
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
            "bmkGuid": bmkGuid,
            "clientCode": documentItems.client.clientCode,
            "categoryType": 0,
            "categoryGuid": '00000000-0000-0000-0000-000000000000',
            "isNew": isNew,
            "items": typedItems.map((e) {
              return {
                "bmlItemGuid": e.guid,
                "weight": e.weight,
                "listPrice": e.listPrice,
                "standPrice": e.standPrice,
                "actionPrice": e.actionPrice,
                "comment": e.comment,
              };
            }).toList(),
          };
          HttpResponseModel response = await API().request_(
            context,
            'POST',
            'Benchmarks/InsertUpdateBenchmarks',
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

  Future<void> fillAllItems() async {
    listAllItems == [];

    Map body_ = {"bmiStatus": 1};

    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Benchmarks/GetBenchmarkItems',
      body_,
    );
    if (response.code == 200) {
      List _list = jsonDecode(response.message) as List;
      listAllItems = _list
          .map(
            (e) => BenchmarkItem(
              guid: e['bmiGuid'],
              itemCode: e['bmiCode'],
              itemName: e['bmiName'],
              category1: e['bmiCategory1'],
              category2: e['bmiCategory2'],
              firm: e['bmiFirm'],
            ),
          )
          .toList();
    }
  }

  void _onSearchChanged(String filterKey_) {
    if (filterKey_.isNotEmpty) {
      for (int i = 0; i < listItems.length; i++) {
        final filter = filterKey_.toLowerCase();
        if (listItems[i].itemCode.toLowerCase().contains(filter) ||
            listItems[i].itemName.toLowerCase().contains(filter)) {
          Utils().scrollToIndex(_scrollController, i, itemExtent: 125);
          break;
        }
      }
    } else {
      Utils().scrollToIndex(_scrollController, 0);
    }
  }

  Future<void> onClientTap() async {
    List<Client> listClient_ = [];
    double debtFilter = double.tryParse(txtDebtFilter.text) ?? 0;

    String selectedSellers = await Utils().getSelectedSellers(treeNodeMain);

    if (selectedSellers == '') {
      Messages(
        context: context,
      ).showSnackBar(lan.getTranslatedText('chooseFilter'), 0);
      return;
    }

    //get selected days of week
    String selectedDaysOfWeek = controllerDaysOfWeekMultiSelect.selectedItems
        .map((e) => e.value.toString())
        .join(',');
    listClient_ = await Utils().getClinetList(
      context: context,
      currentLatitude: _currentLocation.latitude,
      currentLongitude: _currentLocation.longitude,
      selectedSellers: selectedSellers,
      debtLimit: debtFilter.toString(),
      selectedDaysOfWeek: selectedDaysOfWeek,
      category: textClientCategory.text,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClientsPage(documentItems, listClient_, selectedSellers, 2),
      ),
    );
    clientFilterExpansibleController.collapse();
    setState(() {});
  }

  Future<void> onFirmTap() async {
    if (listFirms.isNotEmpty) {
      await CardChoose(context).showCardModalBottomSheet(listFirms, (i) {
        setState(() {
          selectedFirm = listFirms[i];
          selectedCategory1 = '';
          selectedCategory2 = '';
          listCategories1 = [];
          listCategories2 = [];
          listItems = [];
          listCategories1 = listAllItems
              .where((e) => e.firm == selectedFirm)
              .map((e) => e.category1)
              .toSet()
              .toList();
        });
      });
    }
  }

  Future<void> onCategory1Tap() async {
    if (listCategories1.isNotEmpty) {
      await CardChoose(context).showCardModalBottomSheet(listCategories1, (i) {
        setState(() {
          selectedCategory1 = listCategories1[i];
          selectedCategory2 = '';
          listCategories2 = [];
          listItems = listAllItems
              .where(
                (e) =>
                    e.firm == selectedFirm && e.category1 == selectedCategory1,
              )
              .toList();
          listCategories2 = listAllItems
              .where(
                (e) =>
                    e.category1 == selectedCategory1 && e.firm == selectedFirm,
              )
              .map((e) => e.category2)
              .toSet()
              .toList();
          isLoading = false;
        });
      });
    }
  }

  Future<void> onCategory2Tap() async {
    if (listCategories2.isNotEmpty) {
      await CardChoose(context).showCardModalBottomSheet(listCategories2, (i) {
        setState(() {
          selectedCategory2 = listCategories2[i];
          listItems = listAllItems
              .where(
                (e) =>
                    e.firm == selectedFirm &&
                    e.category1 == selectedCategory1 &&
                    e.category2 == selectedCategory2,
              )
              .toList();
          isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    clientFilterExpansibleController.collapse();

    fillElements();
  }

  Widget getWidgetClientFilter() {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ExpansionTile(
            controller: clientFilterExpansibleController,
            title: Text(lan.getTranslatedText('clientFilter')),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: TreeView.simple(
                    expansionBehavior: ExpansionBehavior.collapseOthers,
                    tree: treeNodeMain,
                    showRootNode: false,
                    expansionIndicatorBuilder: (context, node) =>
                        ChevronIndicator.rightDown(
                          padding: EdgeInsets.only(right: 10),
                          tree: node,
                          color: Colors.blue[700],
                        ),
                    indentation: const Indentation(
                      style: IndentStyle.roundJoint,
                    ),
                    builder: (context, node) {
                      int value_ = node.meta?['value'] ?? 0;
                      return Column(
                        children: [
                          TriStateCheckbox(
                            value: value_,
                            label: node.key,
                            onChanged: (newValue) {
                              setState(() {
                                node.meta = {'value': newValue};
                                node.children.forEach((key, node1) {
                                  node1.meta = {'value': newValue};
                                  node1.children.forEach((key, node2) {
                                    node2.meta = {'value': newValue};
                                  });
                                });

                                if (node.parent != null) {
                                  int countNodeParent1 = 0;
                                  node.parent?.children.forEach((key, node1) {
                                    int node1Value = node1.meta?['value'] ?? 0;
                                    if (node1Value > 0) {
                                      countNodeParent1++;
                                    }
                                  });
                                  int valueNodeParent1 = 1;
                                  if (node.parent?.children.length ==
                                      countNodeParent1) {
                                    valueNodeParent1 = 2;
                                  } else if (countNodeParent1 == 0) {
                                    valueNodeParent1 = 0;
                                  }
                                  node.parent?.meta = {
                                    'value': valueNodeParent1,
                                  };

                                  if (node.parent?.parent != null) {
                                    int countNodeParent2Checked = 0,
                                        countNodeParent2Dash = 0;
                                    node.parent?.parent?.children.forEach((
                                      key,
                                      node2,
                                    ) {
                                      int node2Value =
                                          node2.meta?['value'] ?? 0;
                                      if (node2Value == 2) {
                                        countNodeParent2Checked++;
                                      } else if (node2Value == 1) {
                                        countNodeParent2Dash++;
                                      }
                                    });
                                    int valueNodeParent2 = 0;
                                    if (node.parent?.parent?.children.length ==
                                        countNodeParent2Checked) {
                                      valueNodeParent2 = 2;
                                    } else if (countNodeParent2Dash > 0) {
                                      valueNodeParent2 = 1;
                                    }
                                    node.parent?.parent?.meta = {
                                      'value': valueNodeParent2,
                                    };
                                  }
                                }
                              });
                            },
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Widgets().getTextFormField(
                  txtDebtFilter,
                  (v) {},
                  [FilteringTextInputFormatter.digitsOnly],
                  'minDebt',
                  ThemeModule.cTextFieldLabelColor,
                  ThemeModule.cTextFieldFillColor,
                  false,
                  TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Widgets().getTextFormField(
                  textClientCategory,
                  (v) {},
                  [],
                  'category',
                  ThemeModule.cTextFieldLabelColor,
                  ThemeModule.cTextFieldFillColor,
                  false,
                  TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Widgets().getInvoiceMultiSelectWidget(
                  context,
                  controllerDaysOfWeekMultiSelect,
                  'daysOfWeek',
                  'daysOfWeekSelection',
                  Icons.card_giftcard,
                  listDaysOfWeek,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getWidgetItemCard(BenchmarkItem item) {
    return GestureDetector(
      onTap: () async {
        await KeyPad().showItemBenchmarkKeyPadDialog(context, item);
        listAllItems.forEach((element) {
          if (element.guid == item.guid) {
            element.weight = item.weight;
            element.listPrice = item.listPrice;
            element.standPrice = item.standPrice;
            element.actionPrice = item.actionPrice;
          }
        });
        setState(() {});
      },
      child: Slidable(
        closeOnScroll: true,
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            Widgets().getSlideElement(
              'comment',
              Icons.notes,
              () => openCommentDialog(item),
              Colors.yellowAccent.shade100,
            ),
          ],
        ),
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
            color: getItemColor(item),
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

              Row(
                children: [
                  Expanded(
                    child: Widgets().getRichText(
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
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: Widgets().getRichText(
                      lan.getTranslatedText('firm'),
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontFamily: 'poppins_regular',
                        fontSize: 12,
                      ),
                      item.firm,
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontSize: 12,
                        fontFamily: 'poppins_semibold',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Widgets().getRichText(
                      lan.getTranslatedText('categoryShort') + ' 1',
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontFamily: 'poppins_regular',
                        fontSize: 12,
                      ),
                      item.category1,
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontSize: 12,
                        fontFamily: 'poppins_semibold',
                      ),
                    ),
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: Widgets().getRichText(
                      lan.getTranslatedText('categoryShort') + ' 2',
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontFamily: 'poppins_regular',
                        fontSize: 12,
                      ),
                      item.category2.toString(),
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontSize: 12,
                        fontFamily: 'poppins_semibold',
                      ),
                    ),
                  ),
                ],
              ),
              Widgets().getRichText(
                lan.getTranslatedText('comment'),
                TextStyle(
                  color: ThemeModule.cBlackWhiteColor,
                  fontFamily: 'poppins_regular',
                  fontSize: 12,
                ),
                item.comment,
                TextStyle(
                  color: ThemeModule.cBlackWhiteColor,
                  fontSize: 12,
                  fontFamily: 'poppins_semibold',
                ),
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
                  getTypedQuantityWidget(item.standPrice),
                  SizedBox(width: 5),
                  getTypedQuantityWidget(item.actionPrice),
                  SizedBox(width: 5),
                  getTypedQuantityWidget(item.weight),
                  SizedBox(width: 5),
                  getTypedQuantityWidget(item.listPrice),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getItemColor(BenchmarkItem item) {
    if (item.weight > 0 ||
        item.listPrice > 0 ||
        item.standPrice > 0 ||
        item.actionPrice > 0) {
      return ThemeModule.cLightGreenColor;
    } else {
      return ThemeModule.cWhiteBlackColor;
    }
  }

  Widget getItemListWidget() {
    return ListView.builder(
      controller: _scrollController,
      itemExtent: 125,
      itemCount: listItems.length,
      shrinkWrap: true, // Add this
      itemBuilder: (context, index) {
        BenchmarkItem item = listItems[index];
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
    bool isClientChosen = documentItems.client.clientCode != '' ? true : false;
    return Scaffold(
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
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            getWidgetClientFilter(),
                            Widgets().getInvoiceChooseCardWidget(
                              context,
                              documentItems.client.clientName,
                              '${lan.getTranslatedText('code')}:${documentItems.client.clientCode}    ${lan.getTranslatedText('clientDebt')}:${documentItems.client.clientDebt}₼',
                              'chooseClient',
                              Icons.supervisor_account_sharp,
                              isClientChosen,
                              () => onClientTap(),
                            ),
                            Widgets().getInvoiceChooseCardWidget(
                              context,
                              selectedFirm,
                              'firms',
                              'firmsSelection',
                              Icons.business,
                              selectedFirm != '' ? true : false,
                              onFirmTap,
                            ),
                            selectedFirm != ''
                                ? Widgets().getInvoiceChooseCardWidget(
                                    context,
                                    selectedCategory1,
                                    'category1',
                                    'category1Selection',
                                    Icons.category,
                                    selectedCategory1 != '' ? true : false,
                                    onCategory1Tap,
                                  )
                                : Container(),
                            selectedCategory1 != ''
                                ? Widgets().getInvoiceChooseCardWidget(
                                    context,
                                    selectedCategory2,
                                    'category2',
                                    'category2Selection',
                                    Icons.category,
                                    selectedCategory2 != '' ? true : false,
                                    onCategory2Tap,
                                  )
                                : Container(),

                            // listFirms.isNotEmpty
                            //     ? Widgets().getInvoiceMultiSelectWidgetString(
                            //         context,
                            //         'firms',
                            //         'firmsSelection',
                            //         Icons.business,
                            //         listFirms,
                            //         (l) {
                            //           setState(() {
                            //             listCategories1 = [];
                            //             listCategories2 = [];
                            //             List<String> listCategories1_ = [];
                            //             for (String firm in l) {
                            //               listCategories1_.addAll(
                            //                 listAllItems
                            //                     .where((e) => e.firm == firm)
                            //                     .map((e) => e.category1)
                            //                     .toSet(),
                            //               );
                            //             }
                            //             listCategories1 = listCategories1_
                            //                 .toSet()
                            //                 .toList()
                            //                 .map(
                            //                   (e) => DropdownItem(
                            //                     value: e,
                            //                     label: e,
                            //                     selected: true,
                            //                   ),
                            //                 )
                            //                 .toList();
                            //
                            //             List<String> listCategories2_ = [];
                            //             for (String category1 in listCategories1_) {
                            //               listCategories2_.addAll(
                            //                 listAllItems
                            //                     .where(
                            //                       (e) => e.category1 == category1,
                            //                     )
                            //                     .map((e) => e.category2)
                            //                     .toSet(),
                            //               );
                            //             }
                            //             listCategories2 = listCategories2_
                            //                 .toSet()
                            //                 .toList()
                            //                 .map(
                            //                   (e) => DropdownItem(
                            //                     value: e,
                            //                     label: e,
                            //                     selected: true,
                            //                   ),
                            //                 )
                            //                 .toList();
                            //
                            //             listItems = listAllItems
                            //                 .where(
                            //                   (e) => listCategories2_.contains(
                            //                     e.category2,
                            //                   ),
                            //                 )
                            //                 .toList();
                            //           });
                            //         },
                            //       )
                            //     : Container(),
                            // listCategories1.isNotEmpty
                            //     ? Widgets().getInvoiceMultiSelectWidgetString(
                            //         context,
                            //         'category1',
                            //         'category1Selection',
                            //         Icons.category,
                            //         listCategories1,
                            //         (l) {
                            //           setState(() {
                            //             List<String> listCategories2_ = [];
                            //             for (String category1 in l) {
                            //               listCategories2_.addAll(
                            //                 listAllItems
                            //                     .where(
                            //                       (e) => e.category1 == category1,
                            //                     )
                            //                     .map((e) => e.category2)
                            //                     .toSet(),
                            //               );
                            //             }
                            //             listCategories2 = listCategories2_
                            //                 .toSet()
                            //                 .toList()
                            //                 .map(
                            //                   (e) => DropdownItem(
                            //                     value: e,
                            //                     label: e,
                            //                     selected: true,
                            //                   ),
                            //                 )
                            //                 .toList();
                            //
                            //             listItems = listAllItems
                            //                 .where(
                            //                   (e) => listCategories2_.contains(
                            //                     e.category2,
                            //                   ),
                            //                 )
                            //                 .toList();
                            //           });
                            //         },
                            //       )
                            //     : Container(),
                            // listCategories2.isNotEmpty
                            //     ? Widgets().getInvoiceMultiSelectWidgetString(
                            //         context,
                            //         'category2',
                            //         'category2Selection',
                            //         Icons.category,
                            //         listCategories2,
                            //         (l) {
                            //           setState(() {
                            //             listItems = listAllItems
                            //                 .where((e) => l.contains(e.category2))
                            //                 .toList();
                            //           });
                            //         },
                            //       )
                            //     : Container(),
                          ],
                        ),
                      ),
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
