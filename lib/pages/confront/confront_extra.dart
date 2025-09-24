import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/auto_sliding_text.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class ConfrontExtra extends StatefulWidget {
  final String clientCode;
  final String clientName;
  const ConfrontExtra(this.clientCode, this.clientName, {super.key});

  @override
  State<ConfrontExtra> createState() => _ConfrontExtraState();
}

class _ConfrontExtraState extends State<ConfrontExtra> {
  LanguagePack lan = LanguagePack();

  TextEditingController txtDateFirst = TextEditingController(),
      txtDateLast = TextEditingController();

  @override
  void initState() {
    txtDateFirst.text = Utils().getDateFormatForToday(-30);
    txtDateLast.text = Utils().getDateFormatForToday(0);
    super.initState();
  }

  Future<List> getConfrontExtraList() async {
    List listConfrontExtra = [];

    Map bodyConfrontExtra = {
      'userGuid': GlobalParams.userParams.userUID,
      'seller': '',
      'clientCode': widget.clientCode,
      'firstDate': Utils().getDateFormatForInsert(txtDateFirst.text, 0),
      'lastDate': Utils().getDateFormatForInsert(txtDateLast.text, 0),
    };
    HttpResponseModel httpResponseModelClientExtra = await API().request_(
      context,
      'POST',
      'Confronts/GetConfronts',
      bodyConfrontExtra,
    );

    if (context.mounted && httpResponseModelClientExtra.code == 200) {
      listConfrontExtra =
          jsonDecode(httpResponseModelClientExtra.message) as List;
    }

    return listConfrontExtra;
  }

  Widget getDocumentItem(dynamic confrontExtra) {
    TextStyle textStyle = TextStyle(
      color: ThemeModule.cWhiteBlackColor,
      fontFamily: 'poppins_semibold',
      fontSize: 15,
    );
    return Container(
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
                  child: Widgets().getRichText(
                    lan.getTranslatedText('docNumber'),
                    TextStyle(
                      color: ThemeModule.cBlackWhiteColor,
                      fontFamily: 'poppins_reguler',
                      fontSize: 14,
                    ),
                    confrontExtra['docNumber'].toString(),
                    textStyle,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(confrontExtra['docDate'], style: textStyle),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: Widgets().getRichText(
                    lan.getTranslatedText('clientDebt'),
                    TextStyle(
                      color: ThemeModule.cBlackWhiteColor,
                      fontFamily: 'poppins_reguler',
                      fontSize: 14,
                    ),
                    confrontExtra['clientDebt'].toString() + '₼',
                    textStyle,
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: SizedBox(
                    width: 200,
                    child: Widgets().getRichText(
                      lan.getTranslatedText('confrontedDebt'),
                      TextStyle(
                        color: ThemeModule.cBlackWhiteColor,
                        fontFamily: 'poppins_reguler',
                        fontSize: 14,
                      ),
                      confrontExtra['confrontedDebt'].toString() + '₼',
                      textStyle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
          ],
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
                    future: getConfrontExtraList(),
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
