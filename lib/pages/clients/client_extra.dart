import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mplusanalyzer/models/client_extra.dart';
import 'package:mplusanalyzer/models/client_extra_lines.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import '../../utils/api.dart';
import '../../utils/utils.dart';
import '../../widgets/auto_sliding_text.dart';

class ClientExtraPage extends StatefulWidget {
  final String clientCode;
  final String clientName;
  const ClientExtraPage(this.clientCode, this.clientName, {super.key});

  @override
  State<ClientExtraPage> createState() => _ClientExtraPageState();
}

class _ClientExtraPageState extends State<ClientExtraPage> {
  LanguagePack lan = LanguagePack();

  TextEditingController txtDateFirst = TextEditingController(),
      txtDateLast = TextEditingController();

  @override
  void initState() {
    txtDateFirst.text = Utils().getDateFormatForToday(-30);
    txtDateLast.text = Utils().getDateFormatForToday(0);
    super.initState();
  }

  Future<List<ClientExtra>> getClientExtraList() async {
    List<ClientExtra> listClientExtra = [];
    double clientDebt = 0;
    //ClientExtra
    Map bodyClientExtra = {
      'clientCode': widget.clientCode,
      'firstDate': Utils().getDateFormatForInsert(txtDateFirst.text, 0),
      'lastDate': Utils().getDateFormatForInsert(txtDateLast.text, 0),
    };
    HttpResponseModel httpResponseModelClientExtra = await API().request_(
      context,
      'POST',
      'Clients/GetClientExtra',
      bodyClientExtra,
    );

    if (context.mounted && httpResponseModelClientExtra.code == 200) {
      listClientExtra = clientExtraFromJson(
        httpResponseModelClientExtra.message,
      );

      //ClientDebt
      Map bodyClientDebt = {
        'clientCode': widget.clientCode,
        'lastDate': Utils().getDateFormatForInsert(txtDateLast.text, 0),
      };
      HttpResponseModel httpResponseModelClientDebt = await API().request_(
        context,
        'POST',
        'Clients/GetClientDebt',
        bodyClientDebt,
      );

      if (context.mounted && httpResponseModelClientDebt.code == 200) {
        dynamic dataClientDebt = jsonDecode(
          httpResponseModelClientDebt.message,
        );
        clientDebt = double.tryParse(dataClientDebt['result']) ?? 0;
      }
    }
    for (int i = listClientExtra.length - 1; i >= 0; i--) {
      if (i == listClientExtra.length - 1) {
        listClientExtra[i].lineDebt = clientDebt;
      } else {
        clientDebt -= listClientExtra[i + 1].total;
        listClientExtra[i].lineDebt = clientDebt;
      }
    }
    return listClientExtra;
  }

  Future<void> openInvoiceDetails(ClientExtra clientExtra) async {
    List<ClientExtraLines> listClientExtraLines = [];

    Map body = {'docId': clientExtra.id};
    HttpResponseModel httpResponseModel = await API().request_(
      context,
      'POST',
      'Clients/GetClientExtraLines',
      body,
    );

    if (context.mounted && httpResponseModel.code == 200) {
      listClientExtraLines = clientExtraLinesFromJson(
        httpResponseModel.message,
      );
    }

    if (listClientExtraLines.isNotEmpty) {
      setItemModalSheet(
        listClientExtraLines,
        lan.getTranslatedText('chaDocTypes${clientExtra.type}'),
        clientExtra.invoiceNumber,
      );
    }
  }

  Widget getDocumentItem(ClientExtra clientExtra) {
    TextStyle textStyle = TextStyle(
      color: ThemeModule.cWhiteBlackColor,
      fontFamily: 'poppins_semibold',
      fontSize: 15,
    );
    return Slidable(
      closeOnScroll: true,
      endActionPane:
          clientExtra.type == 32 ||
              clientExtra.type == 33 ||
              clientExtra.type == 37 ||
              clientExtra.type == 38
          ? ActionPane(
              extentRatio: 0.3,
              motion: const ScrollMotion(),
              children: [
                SizedBox(width: 2),
                SlidableAction(
                  autoClose: true,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: (_) => openInvoiceDetails(clientExtra),
                  backgroundColor: ThemeModule.cContainerInfoColor,
                  foregroundColor: ThemeModule.cBlackWhiteColor,
                  icon: Icons.info_outline,
                  label: lan.getTranslatedText('details'),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  spacing: 2,
                ),
              ],
            )
          : null,
      child: Container(
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
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      lan.getTranslatedText('chaDocTypes${clientExtra.type}'),
                      style: textStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${clientExtra.total.toStringAsFixed(2)}₼',
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(clientExtra.invoiceNumber, style: textStyle),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(clientExtra.date, style: textStyle),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${clientExtra.lineDebt!.toStringAsFixed(2)}₼',
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setItemModalSheet(
    List<ClientExtraLines> listItems,
    String docType,
    String docNumber,
  ) async {
    await showModalBottomSheet(
      backgroundColor: ThemeModule.cForeColor,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, _setState) => SafeArea(
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.75,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                  child: AutoSlidingText(
                    text: '$docType - $docNumber',
                    style: TextStyle(
                      fontFamily: 'poppins_semibold',
                      color: ThemeModule.cWhiteBlackColor,
                      fontSize: 16,
                    ),
                    duration: const Duration(seconds: 4),
                    direction: Axis.horizontal,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListView.separated(
                      itemCount: listItems.length,
                      itemBuilder: (contextM, index) =>
                          Widgets().getWidgetItemCard(
                            context,
                            listItems[index],
                            widget.clientCode,
                          ),
                      separatorBuilder: (context, index) => SizedBox(height: 3),
                    ),
                  ),
                ),
              ],
            ),
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
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: ThemeModule.cWhiteBlackColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  child: AutoSlidingText(
                    text: widget.clientName,
                    style: TextStyle(
                      fontFamily: 'poppins_medium',
                      fontSize: 20,
                      color: ThemeModule.cBlackWhiteColor,
                    ),
                    direction: Axis.horizontal,
                    duration: Duration(seconds: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}),
        child: Icon(
          Icons.refresh,
          color: ThemeModule.cWhiteBlackColor,
          size: 35,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/main_background.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                repeat: ImageRepeat.noRepeat,
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ThemeModule.cWhiteBlackColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Widgets().getTextFormFieldForDate(
                            context,
                            txtDateFirst,
                            () async {
                              await Utils().setDatePickerValue(
                                context,
                                txtDateFirst,
                                0,
                              );
                            },
                            'firstDate',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Widgets().getTextFormFieldForDate(
                            context,
                            txtDateLast,
                            () async {
                              await Utils().setDatePickerValue(
                                context,
                                txtDateLast,
                                0,
                              );
                            },
                            'lastDate',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: FutureBuilder(
                    future: getClientExtraList(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Widgets().getLoadingWidget(context);
                      } else if (!snapshot.hasData) {
                        return Widgets().getEmptyDataWidget();
                      } else if (snapshot.data!.isEmpty) {
                        return Widgets().getEmptyDataWidget();
                      } else if (snapshot.hasError) {
                        return Widgets().getErrorWidget();
                      } else {
                        return ListView.separated(
                          itemCount: snapshot.data!.length + 1,
                          itemBuilder: (context, index) =>
                              index < snapshot.data!.length
                              ? getDocumentItem(snapshot.data![index])
                              : SizedBox(height: 65),
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: 5),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
