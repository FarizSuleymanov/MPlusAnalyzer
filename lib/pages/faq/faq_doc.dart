import 'dart:convert';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:animated_tree_view/tree_view/widgets/expansion_indicator.dart';
import 'package:animated_tree_view/tree_view/widgets/indent.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mplusanalyzer/models/client.dart';
import 'package:mplusanalyzer/models/document_items.dart';
import 'package:mplusanalyzer/models/faq_answers.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/pages/clients/clients_page.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/widgets/tri_state_checkbox.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';

class FaqDoc extends StatefulWidget {
  final Client? client;
  final List<String> listClientCodesFromDocList;
  const FaqDoc({
    this.client,
    required this.listClientCodesFromDocList,
    super.key,
  });

  @override
  State<FaqDoc> createState() => _FaqDocState();
}

class _FaqDocState extends State<FaqDoc> {
  LanguagePack lan = LanguagePack();
  bool isLoading = true;
  List<TextEditingController> listTextCommentController = [],
      listTextAnswerController = [];
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
  List<Answer> listQuestions = [];
  ExpansibleController clientFilterExpansibleController =
      new ExpansibleController();

  List<List<String>> listVariants = [], listSelectedMultiVariants = [];
  List<String?> listSelectedVariants = [];

  List<List<Uint8List>> listAddedImages = [];
  final controllerDaysOfWeekMultiSelect = MultiSelectController<int>();
  List<DropdownItem<int>> listDaysOfWeek = [];
  LatLng _currentLocation = LatLng(0, 0);
  TextEditingController txtClientCategory = TextEditingController();
  String faqGuid = '';

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
              client.statusFaq = 1;
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
      //get selected days of week
      String selectedDaysOfWeek = controllerDaysOfWeekMultiSelect.selectedItems
          .map((e) => e.value.toString())
          .join(',');
      listClient_ = await Utils().getClinetList(
        context: context,
        currentLatitude: _currentLocation.latitude,
        currentLongitude: _currentLocation.longitude,
        selectedSellers: selectedSellers,
        selectedDaysOfWeek: selectedDaysOfWeek,
      );
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClientsPage(documentItems, listClient_, selectedSellers, 1),
      ),
    );
    await fillElementsAfterChoosingClient();
    clientFilterExpansibleController.collapse();
    setState(() {});
  }

  Future<void> fillElementsAfterChoosingClient() async {
    if (documentItems.client.clientCode != '') {
      HttpResponseModel response = await API().request_(
        context,
        'POST',
        'Faqs/GetQuestionsByClient',
        {"clientCode": documentItems.client.clientCode},
      );
      if (response.code == 200) {
        listQuestions = answersFromJson(response.message);
        listQuestions.forEach((e) {
          listTextCommentController.add(new TextEditingController());
          listTextAnswerController.add(new TextEditingController());
        });
        for (int i = 0; i < listQuestions.length; i++) {
          listTextCommentController.add(new TextEditingController());
          listTextAnswerController.add(new TextEditingController());
          listSelectedVariants.add(null);
          List<String> listVariants_ = [];
          if (listQuestions[i].qstType == '0') {
            HttpResponseModel responseVar = await API().request_(
              context,
              'POST',
              'Faqs/GetVariants',
              {"questionGuid": listQuestions[i].qstGuid},
            );
            if (responseVar.code == 200) {
              List list = jsonDecode(responseVar.message) as List;
              listVariants_ = list.map((e) => e['varText'].toString()).toList();
            }
          } else if (listQuestions[i].qstType == '1') {
            listVariants_ = [
              lan.getTranslatedText('yes'),
              lan.getTranslatedText('no'),
            ];
          }
          listVariants.add(listVariants_);
          listSelectedMultiVariants.add([]);
          listAddedImages.add([]);
        }
      }
    }
    clientFilterExpansibleController.collapse();
  }

  void fillElements() async {
    _currentLocation = await Utils().getCurrentLocation(context);
    treeNodeMain = await Utils().getClientFilterTreeNode(context);
    if (widget.client != null) {
      documentItems.client = widget.client!;
      await fillElementsAfterChoosingClient();
    }
    listDaysOfWeek = Utils().getWeekDays();

    const uuid = Uuid();
    faqGuid = uuid.v4();

    setState(() {
      isLoading = false;
    });
  }

  String getHeaderText() {
    return lan.getTranslatedText('newFaq');
  }

  getPictureFromCamera(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    Uint8List? imagebytes = await FlutterImageCompress.compressWithFile(
      photo!.path,
      quality: 50,
    );
    setState(() {
      listAddedImages[index].add(imagebytes!);
    });
  }

  getPictureFromGallery(int index) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    images.map((e) async {
      Uint8List? imagebytes = await FlutterImageCompress.compressWithFile(
        e.path,
        quality: 50,
      );
      listAddedImages[index].add(imagebytes!);
      setState(() {});
    }).toList();
  }

  getPictures(int index) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lan.getTranslatedText('addImages')),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextButton(
                  onPressed: () {
                    getPictureFromCamera(index);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    lan.getTranslatedText('takePhoto'),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    getPictureFromGallery(index);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    lan.getTranslatedText('galery'),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    lan.getTranslatedText('cancel'),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void removeImageFromList(int questionIndex, int imageIndex) {
    Messages(context: context).showYesNoDialog(
      lan.getTranslatedText('areYouSureYouWantToDeleteThisPhoto'),
      () {
        setState(() {
          listAddedImages[questionIndex].removeAt(imageIndex);
        });
      },
    );
  }

  save() async {
    String msgKey = '';

    List answers_ = [];

    if (documentItems.client.clientCode == '') {
      msgKey = 'clientNotSelected';
    } else if (listQuestions.isEmpty) {
      msgKey = 'theQuestionDoesNotExistForThisClient';
    }
    for (int i = 0; i < listQuestions.length; i++) {
      Answer e = listQuestions[i];
      if (!e.qstCanPass && e.qstType != '3' && e.awsText == '') {
        msgKey = 'questionsMarkedWithStarCannotBeSkipped';
      } else if (!e.qstCanPass &&
          e.qstType == '3' &&
          listAddedImages[i].length == 0) {
        msgKey = 'questionsMarkedWithStarCannotBeSkipped';
      }
      List<String> listImages = listAddedImages[i]
          .map((e) => base64.encode(e))
          .toList();
      Map answer_ = {
        'qstGuid': e.qstGuid,
        'ansGuid': e.ansGuid,
        'clientCode': documentItems.client.clientCode,
        'ansText': e.awsText,
        'ansComment': e.awsComment,
        'images': listImages,
      };
      answers_.add(answer_);
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
          Map body = {'answers': answers_};
          HttpResponseModel response = await API().request_(
            context,
            'POST',
            'Faqs/insertAnswers',
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

  Widget getWidgetClientFilterTree() {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
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
                indentation: const Indentation(style: IndentStyle.roundJoint),
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
                              node.parent?.meta = {'value': valueNodeParent1};

                              if (node.parent?.parent != null) {
                                int countNodeParent2Checked = 0,
                                    countNodeParent2Dash = 0;
                                node.parent?.parent?.children.forEach((
                                  key,
                                  node2,
                                ) {
                                  int node2Value = node2.meta?['value'] ?? 0;
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
              txtClientCategory,
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
                        clientCategory: txtClientCategory.text,
                        debtFilter: -1000000000,
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
    );
  }

  Widget getQuestionImageWidget(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0), //                 <--- border radius here
        ),
      ),
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                getPictures(index);
              },
              child: Text(lan.getTranslatedText('addImages')),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                margin: const EdgeInsets.only(left: 50, right: 50),
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: listAddedImages[index].length,
                  itemBuilder: (BuildContext context, int imageIndex) {
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          removeImageFromList(index, imageIndex);
                        });
                      },
                      child: Image.memory(listAddedImages[index][imageIndex]),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getQuestionVariantsWidget(int index) {
    return ListView.builder(
      primary: false, // Usually fine for nested lists
      physics:
          const ClampingScrollPhysics(), // Good for preventing overscroll in nested lists
      shrinkWrap:
          true, // Necessary for ListView inside another scrollable or Column
      itemCount: listVariants[index].length,
      itemBuilder: (context, index_) {
        return RadioListTile<String>(
          visualDensity: VisualDensity(vertical: -4), // UI preference
          title: Text(listVariants[index][index_]),
          value: listVariants[index][index_],
          groupValue: listSelectedVariants[index],
          onChanged: (String? newValue) {
            // Add null check for newValue before using it with '!'
            if (newValue != null) {
              setState(() {
                listSelectedVariants[index] = newValue;
                listQuestions[index].awsText = newValue;
              });
            }
          },
        );
      },
    );
  }

  Widget getQuestionMultiVariantsWidget(int index) {
    return ListView.builder(
      primary: false,
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: listVariants[index].length,
      itemBuilder: (context, index_) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          visualDensity: VisualDensity(vertical: -4),
          title: Text(listVariants[index][index_]),
          value: listSelectedMultiVariants[index].contains(
            listVariants[index][index_],
          ), // Check if option is in selected list
          onChanged: (bool? isChecked) {
            setState(() {
              if (isChecked == true) {
                listSelectedMultiVariants[index].add(
                  listVariants[index][index_],
                ); // Add if checked
              } else {
                listSelectedMultiVariants[index].remove(
                  listVariants[index][index_],
                ); // Remove if unchecked
              }
              listQuestions[index].awsText = listSelectedMultiVariants[index]
                  .join(';');
            });
          },
        );
      },
    );
  }

  Widget getQuestionCard(int index) {
    Answer answer = listQuestions[index];
    listTextCommentController[index].text = answer.awsComment;
    listTextAnswerController[index].text = answer.awsText;
    String star_ = !listQuestions[index].qstCanPass ? ' *' : '';
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        color: ThemeModule.cScaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  '${index + 1}. ${answer.qstText}$star_',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 5),
              answer.qstType == '0' && !answer.qstMultiAnswer
                  ? getQuestionVariantsWidget(index)
                  : Container(),
              answer.qstType == '0' && answer.qstMultiAnswer
                  ? getQuestionMultiVariantsWidget(index)
                  : Container(),
              answer.qstType == '1'
                  ? getQuestionVariantsWidget(index)
                  : Container(),
              answer.qstType == '2'
                  ? Widgets().getInvoiceTextFieldWidget(
                      context,
                      listTextAnswerController[index],
                      'answer',
                      Icons.question_answer,
                      (v) => listQuestions[index].awsText = v,
                      [LengthLimitingTextInputFormatter(250)],
                    )
                  : Container(),
              answer.qstType == '3'
                  ? getQuestionImageWidget(index)
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Widgets().getInvoiceTextFieldWidget(
                  context,
                  listTextCommentController[index],
                  'comment',
                  Icons.notes,
                  (v) => listQuestions[index].awsComment = v,
                  [LengthLimitingTextInputFormatter(250)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: !isLoading
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      getWidgetClientFilterTree(),
                      Widgets().getInvoiceChooseCardWidget(
                        context,
                        documentItems.client.clientName,
                        '${lan.getTranslatedText('code')}:${documentItems.client.clientCode}',
                        'chooseClient',
                        Icons.supervisor_account_sharp,
                        documentItems.client.clientCode != '' ? true : false,
                        () => onClientTap(),
                      ), //Client
                      documentItems.client.clientCode != ''
                          ? Card(
                              child: Column(
                                children: [
                                  Text(
                                    lan.getTranslatedText('questions'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 5),
                                  ListView.builder(
                                    primary: false,
                                    physics: const ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: listQuestions.length,
                                    itemBuilder: (context, index) =>
                                        getQuestionCard(index),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
              : Widgets().getLoadingWidget(context),
        ),
      ),
    );
  }
}
