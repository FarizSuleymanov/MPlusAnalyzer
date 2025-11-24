import 'package:flutter/material.dart';
import 'package:mplusanalyzer/pages/benchmark/benchmark_page.dart';
import 'package:mplusanalyzer/pages/confront/confront_page.dart';
import 'package:mplusanalyzer/pages/counting/counting_page.dart';
import 'package:mplusanalyzer/pages/faq/faq_page.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chartdata.dart';
import '../models/http_response.dart';
import '../utils/api.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2),
                UserInfo(),
                SizedBox(height: 15),
                Operations(),
                SizedBox(height: 25),
                DailyDocumentChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  LanguagePack lan = LanguagePack();

  String userName = GlobalParams.userParams.userFullName,
      companyName = GlobalParams.params.companyName;

  Future<String> getVersion() async {
    return await Utils().getVersion();
  }

  Widget getWidgetUserInfoCard() {
    String versionLabel = lan.getTranslatedText('version');
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 80,
            padding: EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/icons/user_main.png',
              width: 80,
              height: 80,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'poppins_medium',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'poppins_regular',
                    color: Colors.white,
                  ),
                ),
                FutureBuilder(
                  future: getVersion(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        '$versionLabel: ${snapshot.data}',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'poppins_regular',
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getWidgetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lan.getTranslatedText('userName'),
          style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
        ),
        SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: ThemeModule.cForeColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
            child: getWidgetUserInfoCard(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getWidgetInfo();
  }
}

class Operations extends StatefulWidget {
  const Operations({super.key});

  @override
  State<Operations> createState() => _OperationsState();
}

class _OperationsState extends State<Operations> {
  ThemeModule themeModule = ThemeModule();
  LanguagePack lan = LanguagePack();

  Widget getWidgetOperationItem(
    int module,
    String opName,
    void Function() onTap,
  ) {
    bool havePermission = Utils().havePermission(module);

    return havePermission
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onTap(),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: ThemeModule.cWhiteBlackColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 70,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'assets/icons/$opName.png',
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Text(
                          lan.getTranslatedText(opName),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'poppins_medium',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget getWidgetOperations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lan.getTranslatedText('operations'),
          style: TextStyle(fontSize: 14, fontFamily: 'poppins_medium'),
        ),
        SizedBox(height: 7),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              getWidgetOperationItem(
                1,
                'confront',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfrontPage()),
                ),
              ),
              getWidgetOperationItem(
                2,
                'benchmark',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BenchMarkPage()),
                ),
              ),
              getWidgetOperationItem(
                3,
                'counting',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CountingPage()),
                ),
              ),
              getWidgetOperationItem(
                4,
                'faq',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqPage()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getWidgetOperations();
  }
}

class DailyDocumentChart extends StatefulWidget {
  DailyDocumentChart({Key? key}) : super(key: key);

  @override
  State<DailyDocumentChart> createState() => _DailyDocumentChartState();
}

class _DailyDocumentChartState extends State<DailyDocumentChart> {
  bool isLoading = true;
  List<ChartData> listChartData = [];
  final LanguagePack lan = LanguagePack();
  List<DropdownMenuItem> listDataType = [];
  int selectedDataType = 0;

  Widget getChartWidget(List<ChartData> list, String label) {
    return Center(
      child: !isLoading
          ? SfCircularChart(
              legend: const Legend(
                isVisible: true,
                alignment: ChartAlignment.center,
                position: LegendPosition.bottom,
                itemPadding: 10,
                iconBorderWidth: 0,
                borderWidth: 0,
                padding: 2,
              ),
              title: ChartTitle(
                text: label,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  animationDuration: 500,
                  dataSource: list,
                  radius: '62%',
                  explode: true,
                  explodeGesture: ActivationMode.singleTap,
                  xValueMapper: (ChartData data, _) =>
                      lan.getTranslatedText(data.elName),
                  yValueMapper: (ChartData data, _) => data.elCount,
                  dataLabelMapper: (ChartData data, _) =>
                      lan.getTranslatedText(data.elName),
                  sortingOrder: SortingOrder.descending,
                  legendIconType: LegendIconType.seriesType,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    builder:
                        (
                          dynamic data,
                          dynamic point,
                          dynamic series,
                          int pointIndex,
                          int seriesIndex,
                        ) {
                          return Container(
                            // You can use a Container for better control if needed
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // Important to keep the label compact
                              children: [
                                Text(
                                  lan.getTranslatedText(
                                    data.elName,
                                  ), // First line
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ), // Adjust style as needed
                                  textAlign: TextAlign
                                      .center, // Optional: center the text
                                ),
                                Text(
                                  data.elCount.toString(), // Second line
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ), // Adjust style as needed
                                  textAlign: TextAlign
                                      .center, // Optional: center the text
                                ),
                              ],
                            ),
                          );
                        },
                    connectorLineSettings: const ConnectorLineSettings(
                      type: ConnectorType.curve,
                    ),
                    overflowMode: OverflowMode.trim,
                    showZeroValue: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                ),
              ],
            )
          : Widgets().getLoadingWidget(context),
    );
  }

  Future<List<ChartData>> getChartData(int type) async {
    List<ChartData> list = [];
    try {
      HttpResponseModel response = await API().request_(
        context,
        'POST',
        'Users/GetDashboardReport',
        {'type': type},
      );

      if (response.code == 200) {
        list = chartDataFromJson(response.message);
      }
    } catch (e) {
      e.toString();
    }
    return list;
  }

  Future<void> setDataFromAPI() async {
    listChartData = await getChartData(0);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    listDataType = [
      DropdownMenuItem(
        child: Text(
          lan.getTranslatedText('monthly'),
          style: TextStyle(fontSize: 14),
        ),
        value: 0,
      ),
      DropdownMenuItem(
        child: Text(
          lan.getTranslatedText('daily'),
          style: TextStyle(fontSize: 14),
        ),
        value: 1,
      ),
    ];
    setDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ThemeModule.cWhiteBlackColor,
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: DropdownButton(
                        underline: Container(),
                        items: listDataType,
                        onChanged: (v) async {
                          selectedDataType = v;
                          listChartData = await getChartData(selectedDataType);
                          setState(() {});
                        },
                        value: selectedDataType,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            getChartWidget(
              listChartData,
              selectedDataType == 0
                  ? lan.getTranslatedText('dashboardReportForMonthly')
                  : lan.getTranslatedText('dashboardReportForDaily'),
            ),
          ],
        ),
      ),
    );
  }
}
