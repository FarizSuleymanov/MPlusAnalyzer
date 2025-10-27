import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:animated_tree_view/tree_view/widgets/expansion_indicator.dart';
import 'package:animated_tree_view/tree_view/widgets/indent.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mplusanalyzer/models/client.dart';
import 'package:mplusanalyzer/models/document_items.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/pages/clients/clients_page.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/tri_state_checkbox.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:uuid/uuid.dart';

class ConfrontDoc extends StatefulWidget {
  final dynamic confrontData;
  final Client? client;
  final List<String> listClientCodesFromDocList;
  const ConfrontDoc({
    this.confrontData,
    this.client,
    required this.listClientCodesFromDocList,
    super.key,
  });

  @override
  State<ConfrontDoc> createState() => _ConfrontDocState();
}

class _ConfrontDocState extends State<ConfrontDoc> {
  LanguagePack lan = LanguagePack();
  bool isLoading = true, isClientAgree = false, isNew = true;
  TextEditingController txtCommentController = TextEditingController(),
      txtAmount = TextEditingController(),
      txtDebtFilter = TextEditingController(),
      textClientCategory = TextEditingController();
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
  TreeNode treeNodeMain = TreeNode();
  ExpansibleController clientFilterExpansibleController =
      new ExpansibleController();
  final controllerDaysOfWeekMultiSelect = MultiSelectController<int>();
  List<DropdownItem<int>> listDaysOfWeek = [];
  LatLng _currentLocation = LatLng(0, 0);
  String confrontGuid = '';

  Future<void> onClientTap() async {
    List<Client> listClient_ = [];
    try {
      List listClientDynamic = await SessionManager().get(
        'optimizedClientList',
      );
      listClient_ = listClientDynamic
          .map(
            (e) => Client(
              clientCode: e['clientCode'],
              clientName: e['clientName'],
              seller: e['seller'],
              clientLatitude: e['clientLatitude'],
              clientLongitude: e['clientLongitude'],
              clientDebt: e['clientDebt'],
              lastConfrontDate: e['lastConfrontDate'],
              lastFaqDate: e['lastFaqDate'],
              lastBenchmarkDate: e['lastBenchmarkDate'],
              distance: e['distance'],
              statusConfront: e['statusConfront'],
              statusFaq: e['statusFaq'],
              statusBmk: e['statusBmk'],
            ),
          )
          .toList();
      if (widget.listClientCodesFromDocList.isNotEmpty) {
        listClient_ = listClient_.map((client) {
          widget.listClientCodesFromDocList.forEach((cl) {
            if (cl == client.clientCode) {
              client.statusConfront = 1;
            }
          });
          return client;
        }).toList();
      }
    } catch (e) {}
    String selectedSellers = await Utils().getSelectedSellers(treeNodeMain);

    if (selectedSellers == '') {
      Messages(
        context: context,
      ).showSnackBar(lan.getTranslatedText('chooseFilter'), 0);
      return;
    }

    if (listClient_.isEmpty) {
      double debtFilter = double.tryParse(txtDebtFilter.text) ?? 0;

      //get selected days of week
      String selectedDaysOfWeek = controllerDaysOfWeekMultiSelect.selectedItems
          .map((e) => e.value.toString())
          .join(',');
      listClient_ = await Utils().getClientList(
        context: context,
        currentLatitude: _currentLocation.latitude,
        currentLongitude: _currentLocation.longitude,
        selectedSellers: selectedSellers,
        debtLimit: debtFilter.toString(),
        selectedDaysOfWeek: selectedDaysOfWeek,
        category: textClientCategory.text,
      );
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClientsPage(documentItems, listClient_, selectedSellers, 0),
      ),
    );
    clientFilterExpansibleController.collapse();
    setState(() {});
  }

  void fillElements() async {
    _currentLocation = await Utils().getCurrentLocation(context);

    txtDebtFilter.text = '1000';

    if (widget.confrontData != null) {
      isNew = false;
      confrontGuid = widget.confrontData['confrontGuid'];
      documentItems.client.clientCode = widget.confrontData['clientCode'];
      documentItems.client.clientName = widget.confrontData['clientName'];
      documentItems.client.clientDebt = widget.confrontData['clientDebt']
          .toDouble();
      documentItems.client.seller = widget.confrontData['seller'];

      isClientAgree = widget.confrontData['isClientAgree'];
      txtAmount.text = widget.confrontData['confrontedDebt'].toString();
      txtCommentController.text = widget.confrontData['note'];
    } else {
      const uuid = Uuid();
      confrontGuid = uuid.v4();
    }

    if (widget.client != null) {
      documentItems.client = widget.client!;
    }
    treeNodeMain = await Utils().getClientFilterTreeNode(context);
    //clientFilterExpansibleController.collapse();

    listDaysOfWeek = Utils().getWeekDays();

    setState(() {
      isLoading = false;
    });
  }

  String getHeaderText() {
    if (widget.confrontData != null) {
      return '${widget.confrontData['docNumber']}';
    } else {
      return lan.getTranslatedText('newConfront');
    }
  }

  save() async {
    String msgKey = '';
    double amount = double.tryParse(txtAmount.text) ?? 0;
    if (documentItems.client.clientCode == '') {
      msgKey = 'clientNotSelected';
    } else if (amount == 0) {
      msgKey = 'confrontDebtNotEntered';
    }

    if (msgKey != '') {
      Messages(context: context).showSnackBar(lan.getTranslatedText(msgKey), 0);
      setState(() {
        isLoading = false;
      });
      return;
    }

    Messages(context: context).showYesNoDialog(
      lan.getTranslatedText('areYouSureYouWantToSave'),
      () async {
        try {
          Map body = {
            "confrontGuid": confrontGuid,
            "userGuid": GlobalParams.userParams.userUID,
            "docDate": Utils().getDateFormatForTodayForInsert(),
            "seller": documentItems.client.seller,
            "clientCode": documentItems.client.clientCode,
            "clientName": documentItems.client.clientName,
            "clientDebt": documentItems.client.clientDebt,
            "confrontedDebt": double.tryParse(txtAmount.text) ?? 0,
            "note": txtCommentController.text,
            "isClientAgree": isClientAgree,
            "isNew": isNew,
          };
          HttpResponseModel response = await API().request_(
            context,
            'POST',
            'Confronts',
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

  @override
  void initState() {
    clientFilterExpansibleController.expand();

    fillElements();
    super.initState();
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
              GlobalParams.params.googleApiKey != ''
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          String selectedDaysOfWeek =
                              controllerDaysOfWeekMultiSelect.selectedItems
                                  .map((e) => e.value.toString())
                                  .join(',');
                          await Utils().optimizeRoutes(
                            context: context,
                            treeNode: treeNodeMain,
                            clLatitude: _currentLocation.latitude,
                            clLongitude: _currentLocation.longitude,
                            clientCategory: textClientCategory.text,
                            debtFilter:
                                double.tryParse(txtDebtFilter.text) ?? 0,
                            selectedDaysOfWeek: selectedDaysOfWeek,
                          );
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Text(lan.getTranslatedText('optimizeRoutes')),
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
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
              SizedBox(width: 10),
            ],
            title: Align(
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
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: !isLoading
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
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
                      ), //Client
                      Widgets().getInvoiceTextFieldWidget(
                        context,
                        txtAmount,
                        'confrontTotal',
                        Icons.monetization_on,
                        (v) => txtAmount.text = v,
                        [
                          FilteringTextInputFormatter.deny(
                            ',',
                            replacementString: '.',
                          ),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d{0,2})'),
                          ),
                        ],
                        textInputType: TextInputType.number,
                      ),

                      Widgets().getInvoiceTextFieldWidget(
                        context,
                        txtCommentController,
                        'comment',
                        Icons.notes,
                        (v) => txtCommentController.text = v,
                        [LengthLimitingTextInputFormatter(250)],
                      ),
                      Widgets().getInvoiceCheckBoxWidget(
                        context,
                        isClientAgree,
                        'isClientAgree',
                        true,
                        Icons.contact_page,
                        (v) => setState(() => isClientAgree = v),
                      ),
                    ],
                  ),
                ),
              )
            : Widgets().getLoadingWidget(context),
      ),
    );
  }
}
