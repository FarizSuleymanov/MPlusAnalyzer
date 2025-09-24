import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/pages/counting/counting_doc.dart';
import 'package:mplusanalyzer/reports/printpreview.dart';
import 'package:mplusanalyzer/reports/report_counting.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/auto_sliding_text.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class CountingPage extends StatefulWidget {
  const CountingPage({super.key});

  @override
  State<CountingPage> createState() => _CountingPageState();
}

class _CountingPageState extends State<CountingPage> {
  LanguagePack lan = LanguagePack();
  List listDocuments_ = [];
  bool isLoading = true;

  @override
  void initState() {
    setDocumentList();
    super.initState();
  }

  Future<void> setDocumentList() async {
    Map body = {
      "userGuid": GlobalParams.userParams.userUID,
      "firstDate": Utils().getDateFormatForTodayForInsert(),
      "lastDate": Utils().getDateFormatForTodayForInsert(),
    };
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Countings/GetCountingDocuments',
      body,
    );

    if (response.code == 200) {
      listDocuments_ = jsonDecode(response.message) as List;
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
          Map body = {"cntGuid": docGuid};
          HttpResponseModel response = await API().request_(
            context,
            'DELETE',
            'Countings/DeleteCountingDocuments',
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
      MaterialPageRoute(builder: (context) => CountingDoc(doc)),
    );
    setDocumentList();
  }

  Future<void> print(dynamic doc) async {
    // Get CountingLines
    List countingLines = [];
    HttpResponseModel responseLines = await API().request_(
      context,
      'POST',
      'Countings/GetCountingsDocLines',
      {'cntGuid': doc['cntGuid']},
    );
    if (responseLines.code == 200) {
      countingLines = jsonDecode(responseLines.message) as List;
    }

    Uint8List pdf = await ReportCounting().getChequeDocument(
      row: doc,
      countingLines: countingLines,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrintPreview(pdf)),
      );
    }
  }

  Widget getWidgetDocumentCard(Map<String, dynamic> documentData) {
    String docGuid = documentData['cntGuid'].toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Slidable(
        closeOnScroll: true,

        endActionPane: ActionPane(
          extentRatio: 0.9,
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
            Widgets().getSlideElement(
              'print',
              Icons.print,
              () => print(documentData),
              Colors.indigoAccent,
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
                      Text(
                        documentData['cntDocNumber'].toString(),
                        style: TextStyle(
                          color: ThemeModule.cWhiteBlackColor,
                          fontSize: 14,
                          fontFamily: 'poppins_bold',
                        ),
                      ),
                      Text(
                        documentData['cntDocDate'],
                        style: TextStyle(
                          color: ThemeModule.cBlackWhiteColor,
                          fontSize: 14,
                          fontFamily: 'poppins_medium',
                        ),
                      ),
                      Text(
                        documentData['cntWarehouseCode'].toString(),
                        style: TextStyle(
                          color: ThemeModule.cWhiteBlackColor,
                          fontSize: 14,
                          fontFamily: 'poppins_medium',
                        ),
                      ),
                      AutoSlidingText(
                        text: documentData['cntWarehouseName'],
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
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       Expanded(
        //         flex: 7,
        //         child: Widgets().getRichText(
        //           lan.getTranslatedText('clientDebt'),
        //           TextStyle(
        //             color: ThemeModule.cBlackWhiteColor,
        //             fontFamily: 'poppins_reguler',
        //             fontSize: 12,
        //           ),
        //           documentData['clientDebt'].toString() + '₼',
        //           TextStyle(
        //             color: Colors.red,
        //             fontFamily: 'poppins_semibold',
        //             fontSize: 10,
        //           ),
        //         ),
        //       ),
        //
        //       Expanded(
        //         flex: 5,
        //         child: Widgets().getRichText(
        //           lan.getTranslatedText('confrontedDebt'),
        //           TextStyle(
        //             color: ThemeModule.cBlackWhiteColor,
        //             fontFamily: 'poppins_reguler',
        //             fontSize: 12,
        //           ),
        //           documentData['confrontedDebt'].toString() + '₼',
        //           TextStyle(
        //             color: Colors.red,
        //             fontFamily: 'poppins_semibold',
        //             fontSize: 10,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
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
              SizedBox(width: 7),
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
                    lan.getTranslatedText('counting'),
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
