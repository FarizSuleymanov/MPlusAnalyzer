import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/pages/benchmark/benchmark_doc.dart';
import 'package:mplusanalyzer/pages/clients/client_extra.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/auto_sliding_text.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class BenchMarkPage extends StatefulWidget {
  const BenchMarkPage({super.key});

  @override
  State<BenchMarkPage> createState() => _BenchMarkPageState();
}

class _BenchMarkPageState extends State<BenchMarkPage> {
  LanguagePack lan = LanguagePack();
  List listDocuments_ = [];
  List<String> listSellers = [];
  String selectedAgent = 'all';
  bool isLoading = true;
  List<String> listClientCodesFromDocList = [];

  @override
  void initState() {
    setDocumentList();
    super.initState();
  }

  Future<void> setDocumentList() async {
    listDocuments_ = [];
    Map body = {
      "userGuid": GlobalParams.userParams.userUID,
      "firstDate": Utils().getDateFormatForTodayForInsert(),
      "lastDate": Utils().getDateFormatForTodayForInsert(),
      "seller": selectedAgent == 'all' ? '' : selectedAgent,
    };
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Benchmarks/GetBenchmarks',
      body,
    );

    if (response.code == 200) {
      listDocuments_ = jsonDecode(response.message) as List;
    }

    if (listDocuments_.isNotEmpty) {
      listSellers.add('all');
      listDocuments_.forEach((e) => listSellers.add(e['seller'].toString()));
      listSellers = listSellers.toSet().toList();

      listClientCodesFromDocList = listDocuments_
          .map((e) => e['clientCode'].toString())
          .toSet()
          .toList();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteDocument(String docGuid) async {
    Messages(context: context).showYesNoDialog(
      lan.getTranslatedText('areYouSureYouWantToDeleteThat'),
      () async {
        try {
          Map body = {"bmkGuid": docGuid};
          HttpResponseModel response = await API().request_(
            context,
            'DELETE',
            'Benchmarks',
            body,
          );

          if (response.code == 200) {
            Messages(
              context: context,
            ).showSnackBar(lan.getTranslatedText('documentDeleted'), 1);
          }

          setDocumentList();
        } catch (e) {
          Messages(
            context: context,
          ).showWarningDialog(lan.getTranslatedText('anErrorOccurred'));
        }
      },
    );
  }

  Future<void> openDocument(dynamic doc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BenchmarkDoc(doc, listClientCodesFromDocList),
      ),
    );
    setDocumentList();
  }

  Widget getWidgetDocumentCard(Map<String, dynamic> documentData) {
    String docGuid = documentData['bmkGuid'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Slidable(
        closeOnScroll: true,
        startActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            Widgets().getSlideElement(
              'clientExtra',
              Icons.speaker_notes,
              () async {
                String clientCode = documentData['clientCode'];
                String clientName = documentData['clientName'];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ClientExtraPage(clientCode, clientName),
                  ),
                );
              },
              Colors.lightBlueAccent,
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: 0.6,
          motion: const ScrollMotion(),
          children: [
            Widgets().getSlideElement(
              'revise',
              Icons.note_alt_outlined,
              () => openDocument(documentData),
              Colors.yellowAccent.shade100,
            ),
            Widgets().getSlideElement(
              'delete',
              Icons.delete_outline,
              () => deleteDocument(docGuid),
              Colors.orangeAccent,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeModule.cWhiteBlackColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: ThemeModule.cBlackWhiteColor.withAlpha(40),
                blurRadius: 1,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: getDocumentCard(documentData),
        ),
      ),
    );
  }

  Widget getDocumentCard(dynamic documentData) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ThemeModule.cBlackWhiteColor.withAlpha(40),
                blurRadius: 1,
                offset: Offset(2, 2),
              ),
            ],
            color: ThemeModule.cForeColor,
            border: Border.all(width: 1, color: ThemeModule.cWhiteBlackColor),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 3,
              left: 8,
              top: 3,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: ThemeModule.cWhiteBlackColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/client.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AutoSlidingText(
                        text: documentData['clientName'],
                        style: TextStyle(
                          color: ThemeModule.cWhiteBlackColor,
                          fontSize: 14,
                          fontFamily: 'poppins_bold',
                        ),
                      ),
                      Text(
                        documentData['docDate'],
                        style: TextStyle(
                          color: ThemeModule.cBlackWhiteColor,
                          fontSize: 14,
                          fontFamily: 'poppins_medium',
                        ),
                      ),
                      Text(
                        documentData['docNumber'].toString(),
                        style: TextStyle(
                          color: ThemeModule.cWhiteBlackColor,
                          fontSize: 14,
                          fontFamily: 'poppins_medium',
                        ),
                      ),
                      Text(
                        documentData['seller'],
                        style: TextStyle(
                          color: ThemeModule.cWhiteBlackColor,
                          fontSize: 14,
                          fontFamily: 'poppins_light',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              MenuAnchor(
                builder:
                    (
                      BuildContext context,
                      MenuController controller,
                      Widget? child,
                    ) {
                      return GestureDetector(
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ThemeModule.cWhiteBlackColor,
                          ),
                          child: Icon(
                            size: 24,
                            Icons.filter_alt_outlined,
                            color: selectedAgent == 'all'
                                ? ThemeModule.cForeColor
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                menuChildren: [
                  SizedBox(
                    height: (48 * listSellers.length).toDouble(),
                    width: 150,
                    child: ListView.builder(
                      primary: false,
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: listSellers.length,
                      itemBuilder: (context, index) => MenuItemButton(
                        onPressed: () => setState(() {
                          selectedAgent = listSellers[index];
                          setDocumentList();
                        }),
                        child: Text(
                          lan.getTranslatedText(listSellers[index]),
                          style: TextStyle(
                            fontFamily: selectedAgent == listSellers[index]
                                ? 'poppins_semibold'
                                : 'poppins_regular',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 7),
              GestureDetector(
                onTap: () async {
                  await openDocument(null);
                  setState(() {});
                },
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ThemeModule.cWhiteBlackColor,
                  ),
                  child: Icon(
                    size: 24,
                    Icons.add,
                    color: ThemeModule.cForeColor,
                  ),
                ),
              ),
              SizedBox(width: 5),
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
                    lan.getTranslatedText('benchmark'),
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
      body: RefreshIndicator(
        onRefresh: setDocumentList,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/main_background.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                repeat: ImageRepeat.noRepeat,
              ),
            ),
            child: !isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) =>
                          index != listDocuments_.length
                          ? getWidgetDocumentCard(listDocuments_[index])
                          : SizedBox(height: 40),
                      separatorBuilder: (context, index) => SizedBox(height: 0),
                      itemCount: listDocuments_.length + 1,
                    ),
                  )
                : Widgets().getLoadingWidget(context),
          ),
        ),
      ),
    );
  }
}
