import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/image_viewer.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';

class FaqDocView extends StatefulWidget {
  final dynamic document;
  const FaqDocView({this.document, super.key});

  @override
  State<FaqDocView> createState() => _FaqDocViewState();
}

class _FaqDocViewState extends State<FaqDocView> {
  bool isLoading = true;
  List listItems = [];
  LanguagePack lan = LanguagePack();

  String getHeaderText() {
    return '${widget.document['docNumber']}';
  }

  @override
  void initState() {
    fillElements();
    super.initState();
  }

  void fillElements() async {
    Map body = {
      "firstDate": Utils().getDateFormatForTodayForInsert(),
      "lastDate": Utils().getDateFormatForTodayForInsert(),
      "docNumber": widget.document['docNumber'],
    };
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Faqs/GetAnswersReport',
      body,
    );

    if (response.code == 200) {
      listItems = jsonDecode(response.message) as List;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<File> uint8ListToFile(Uint8List data, String filePath) async {
    final file = File(filePath);
    return await file.writeAsBytes(data);
  }

  Future<String> getTempFilePath(String fileName) async {
    final Directory dir = await getTemporaryDirectory();
    return '${dir.path}/$fileName';
  }

  showImages(String ansGuid) async {
    List listImagesName = [];
    List<File> imgList = [];
    Map body = {"ansGuid": ansGuid};
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Faqs/GetAnsPicName',
      body,
    );

    if (response.code == 200) {
      listImagesName = jsonDecode(response.message) as List;
    }

    for (int i = 0; i < listImagesName.length; i++) {
      try {
        String fileName = listImagesName[i]['result'];
        Map body_ = {"picName": fileName};
        StreamedResponse response_ = await API().requestStream_(
          context,
          'POST',
          'Faqs/GetAnsPicure',
          body_,
        );

        if (response_.statusCode == 200) {
          List<List<int>> chunks = [];
          int downloadedBytes = 0;

          await for (List<int> chunk in response_.stream) {
            chunks.add(chunk);
            downloadedBytes += chunk.length;
          }
          final Uint8List bytes = Uint8List(downloadedBytes);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }

          String filePath = await getTempFilePath(fileName);
          File file = await uint8ListToFile(bytes, filePath);
          imgList.add(file);
        }
      } catch (e) {
        e.toString();
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageViewer(imgList)),
    );
  }

  Widget getWidgetItemCard(int index, dynamic item) {
    TextStyle textStyle = TextStyle(
      color: ThemeModule.cWhiteBlackColor,
      fontFamily: 'poppins_semibold',
      fontSize: 15,
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${item['question']}',
              textAlign: TextAlign.left,
              style: textStyle,
            ),
            SizedBox(height: 5),
            Text(
              '${lan.getTranslatedText('type')}: ${item['questionTypeName']}',
              style: textStyle,
            ),
            SizedBox(height: 5),
            item['questionType'] == 3
                ? TextButton.icon(
                    onPressed: () => showImages(item['ansGuid']),
                    icon: Icon(Icons.image, color: textStyle.color),
                    label: Text(
                      lan.getTranslatedText('viewImages'),
                      style: textStyle,
                    ),
                  )
                : Text(
                    '${lan.getTranslatedText('answer')}: ${item['answer']}',
                    style: textStyle,
                  ),
            SizedBox(height: 5),
            Text(
              '${lan.getTranslatedText('comment')}: ${item['comment']}',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemListWidget() {
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        dynamic item = listItems[index];
        return getWidgetItemCard(index, item);
      },
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
              ? Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.account_circle, size: 40),
                        title: Text(
                          widget.document['clientName'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.document['clientCode'] ?? ''),
                      ),
                    ), //Client

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
