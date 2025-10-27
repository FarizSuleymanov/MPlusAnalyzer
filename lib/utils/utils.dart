import 'dart:convert';
import 'dart:io';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mplusanalyzer/models/client.dart';
import 'package:mplusanalyzer/models/google_directions.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart' hide Route;

import '../models/http_response.dart';
import 'api.dart';
import 'global_params.dart';

class Utils {
  LanguagePack lan = LanguagePack();

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  LocationSettings getLocationSettings() {
    late LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 20),
      );
    } else if (Platform.isAndroid) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = LocationSettings(accuracy: LocationAccuracy.high);
    }
    return locationSettings;
  }

  Future<String> checkLocationServiceAndPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return lan.getTranslatedText('locationServicesAreDisabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return lan.getTranslatedText('locationPermissionsAreDenied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return lan.getTranslatedText('locationPermissionsArePermanentlyDenied');
    }
    return '';
  }

  Future<void> openNavigationApp(String location_) async {
    String navigationUrl = 'geo:$location_';
    await launchUrl(
      Uri.parse(navigationUrl),
      mode: LaunchMode.externalApplication,
    );

    // final Uri url = Uri.parse(
    //   'https://waze.com/ul?ll=$location_&navigate=yes&zoom=17',
    // );
    //await launchUrl(url);
  }

  getDateFormatForToday(int addedDays) {
    DateTime now = DateTime.now();
    now = now.add(Duration(days: addedDays));
    return formatDate(now, [dd, '.', mm, '.', yyyy]);
  }

  getDateFormatForInsert(String strDate, int type) {
    String date_ =
        strDate.substring(6) +
        strDate.substring(3, 5) +
        strDate.substring(0, 2);
    if (type == 1) {
      date_ += ' 23:59:59';
    }
    return date_;
  }

  setDatePickerValue(
    BuildContext context,
    TextEditingController txtDate,
    int addedDays,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('en', 'GB'),
    );
    if (pickedDate != null) {
      pickedDate = pickedDate.add(Duration(days: addedDays));
      txtDate.text = formatDate(pickedDate, [dd, '.', mm, '.', yyyy]);
    }
  }

  getDateFormatForTodayForInsert() {
    DateTime now = DateTime.now();
    return formatDate(now, [yyyy, mm, dd]);
  }

  Future<TreeNode> getClientFilterTreeNode(BuildContext context) async {
    TreeNode treeNodeMain = TreeNode();
    dynamic dynSavedClientFilter = await SessionManager().get('clientFilter');
    String strSavedClientFilter = dynSavedClientFilter != null
        ? dynSavedClientFilter.toString()
        : '';
    List<String> listSavedClientFilter = strSavedClientFilter.split(',');
    if (listSavedClientFilter.length == 1 && listSavedClientFilter[0] == '') {
      listSavedClientFilter = [];
    }

    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Users/GetSellers',
      {"userGuid": GlobalParams.userParams.userUID},
    );
    if (response.code == 200) {
      List listSellers = jsonDecode(response.message) as List;
      listSellers = listSellers.where((e) => e['selected'] == true).toList();
      List<String> listRegions = listSellers
          .map((r) => r['region'].toString())
          .toSet()
          .toList();

      listRegions.forEach((r) {
        TreeNode treeNodeRegions = TreeNode(key: r, data: false);

        List<String> listChiefs = listSellers
            .where((c) => c['region'].toString() == r)
            .map((c) => c['chief'].toString())
            .toList()
            .toSet()
            .toList();

        int countSelectedChiefs = 0, countHalfSelectedChiefs = 0;
        listChiefs.forEach((c) {
          TreeNode treeNodeChiefs = TreeNode(key: c);
          List listSellerByChief = listSellers
              .where(
                (s) =>
                    s['region'].toString() == r && s['chief'].toString() == c,
              )
              .toList();
          int countSelectedSellers = 0;
          listSellerByChief.forEach((s) {
            TreeNode sellerNode = TreeNode(key: s['seller']);
            bool isSellerSelected = false;
            String sellerCode = s['seller'].toString().substring(
              0,
              s['seller'].toString().indexOf(' '),
            );
            if (listSavedClientFilter
                    .where((e) => e == sellerCode)
                    .isNotEmpty ||
                listSavedClientFilter.isEmpty) {
              isSellerSelected = true;
              countSelectedSellers++;
            }
            sellerNode.meta = {'value': isSellerSelected ? 2 : 0};
            treeNodeChiefs.add(sellerNode);
          });
          int vChiefSelected = 0;

          if (listSellerByChief.length == countSelectedSellers) {
            vChiefSelected = 2;
            countSelectedChiefs++;
          } else if (countSelectedSellers > 0 &&
              countSelectedSellers < listSellerByChief.length) {
            vChiefSelected = 1;
            countHalfSelectedChiefs++;
          }
          treeNodeChiefs.meta = {'value': vChiefSelected};
          treeNodeRegions.add(treeNodeChiefs);
        });

        int vRegionSelected = 0;

        if (listChiefs.length == countSelectedChiefs) {
          vRegionSelected = 2;
        } else if (countHalfSelectedChiefs > 0) {
          vRegionSelected = 1;
        }

        treeNodeRegions.meta = {'value': vRegionSelected};
        treeNodeMain.add(treeNodeRegions);
      });
    }
    return treeNodeMain;
  }

  Future<List<Client>> getClientList({
    required BuildContext context,
    required double currentLatitude,
    required double currentLongitude,
    String sellerCode = 'all',
    required String selectedSellers,
    String debtLimit = '-1000000000',
    String selectedDaysOfWeek = '',
    String category = '',
  }) async {
    List<Client> listClients = [];
    category = category.replaceAll(' ', '');

    Map body = {
      "userLatitude": currentLatitude,
      "userLongitude": currentLongitude,
      "seller": sellerCode == 'all' ? '' : sellerCode,
      "rootDays": selectedDaysOfWeek,
      "filterConditions": [
        {
          "isUsed": true,
          "columnName": "seller",
          "condition": ",,,",
          "valueX": selectedSellers,
          "valueY": "",
        },
        {
          "isUsed": true,
          "columnName": "clientDebt",
          "condition": ">>>",
          "valueX": debtLimit,
          "valueY": "",
        },
        {
          "isUsed": category != '' ? true : false,
          "columnName": "category",
          "condition": ",,,",
          "valueX": category,
          "valueY": "",
        },
      ],
    };
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Clients/GetClients',
      body,
    );
    if (response.code == 200) {
      listClients = clientFromJson(response.message);
    }
    return listClients;
  }

  Future<LatLng> getCurrentLocation(BuildContext context) async {
    LatLng _currentLocation = LatLng(0, 0);
    try {
      String errorMessage = await Utils().checkLocationServiceAndPermission();
      if (errorMessage.isNotEmpty) {
        Messages(context: context).showSnackBar(errorMessage, 0);
        return _currentLocation;
      }
      LocationSettings locationSettings = Utils().getLocationSettings();

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      Messages(context: context).showSnackBar('Error getting location: $e', 0);
    } finally {
      return _currentLocation;
    }
  }

  Future<List> getConfrontDocumentListForCurrentDay(
    BuildContext context,
    String selectedAgent,
  ) async {
    List list = [];
    Map body = {
      "userGuid": GlobalParams.userParams.userUID,
      "firstDate": Utils().getDateFormatForTodayForInsert(),
      "lastDate": Utils().getDateFormatForTodayForInsert(),
      "seller": selectedAgent == 'all' ? '' : selectedAgent,
      "clientCode": "",
    };
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Confronts/GetConfronts',
      body,
    );

    if (response.code == 200) {
      list = jsonDecode(response.message) as List;
    }
    return list;
  }

  void scrollToIndex(
    ScrollController _scrollController,
    int index, {
    double itemExtent = 105.0,
  }) {
    _scrollController.animateTo(
      index * itemExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  optimizeRoutes({
    required BuildContext context,
    required TreeNode treeNode,
    required double debtFilter,
    required String selectedDaysOfWeek,
    required String clientCategory,
    required double clLatitude,
    required double clLongitude,
  }) async {
    String selectedSellers = await getSelectedSellers(treeNode);

    if (selectedSellers == '') {
      Messages(
        context: context,
      ).showSnackBar(lan.getTranslatedText('chooseFilter'), 0);
      return;
    }

    //double debtFilter = double.tryParse(debtFilter) ?? 0;

    //get selected days of week

    List<Client> listClient = await Utils().getClientList(
      context: context,
      currentLatitude: clLatitude,
      currentLongitude: clLongitude,
      selectedSellers: selectedSellers,
      debtLimit: debtFilter.toString(),
      selectedDaysOfWeek: selectedDaysOfWeek,
      category: clientCategory,
    );
    if (listClient.isNotEmpty) {
      List<Client> listClientFirst24 = listClient.take(24).toList();
      Client lastClient = listClientFirst24.last;
      listClientFirst24.removeLast();

      String origin = '${clLatitude},${clLongitude}',
          destination =
              '${lastClient.clientLatitude},${lastClient.clientLongitude}',
          waypoints = listClientFirst24
              .map((e) => '${e.clientLatitude},${e.clientLongitude}')
              .join('|');

      String urlGooleDirections =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$origin'
          '&destination=$destination'
          '&waypoints=optimize:true|$waypoints'
          '&units=metric'
          '&key=${GlobalParams.params.googleApiKey}';
      HttpResponseModel response = await API().requestGeneral_(
        context,
        'GET',
        urlGooleDirections,
      );
      if (response.code == 200) {
        GoogleDirections googleDirections = googleDirectionsFromJson(
          response.message,
        );
        if (googleDirections.error_message != '') {
          Messages(
            context: context,
          ).showWarningDialog('Google API:' + googleDirections.error_message!);

          return;
        }
        List<Client> listClientOptimized = [];
        if (googleDirections.routes.isEmpty) {
          Messages(
            context: context,
          ).showSnackBar(lan.getTranslatedText('optimizationFailed'), 1);

          return;
        }
        double distance = 0;
        Route route = googleDirections.routes[0];
        for (int i = 0; i < route.legs.length; i++) {
          int ordNum = 0;
          if (i == route.legs.length - 1) {
            ordNum = i;
          } else {
            ordNum = route.waypointOrder[i];
          }
          Client _client = listClient[ordNum];
          distance += (route.legs[i].distance.value / 1000);
          _client.distance = distance;
          listClientOptimized.add(_client);
        }

        listClientOptimized.addAll(listClient.skip(listClientOptimized.length));
        await SessionManager().set(
          'optimizedClientList',
          clienToJson(listClientOptimized),
        );
      }
    } else {
      await SessionManager().remove('optimizedClientList');
    }

    Messages(
      context: context,
    ).showSnackBar(lan.getTranslatedText('optimizationFinished'), 1);
  }

  Future<String> getSelectedSellers(TreeNode treeNode) async {
    String selectedSellers = '';
    treeNode.children.forEach((key, nodeRegion) {
      nodeRegion.children.forEach((key, nodeChief) {
        nodeChief.children.forEach((key, nodeSeller) {
          int selected_ = nodeSeller.meta?['value'] ?? 0;
          if (selected_ == 2) {
            selectedSellers +=
                nodeSeller.key.substring(0, nodeSeller.key.indexOf(' ')) + ',';
          }
        });
      });
    });
    if (selectedSellers == '') {
      return '';
    }
    selectedSellers = selectedSellers.substring(0, selectedSellers.length - 1);

    await SessionManager().set('clientFilter', selectedSellers);
    return selectedSellers;
  }

  List<DropdownItem<int>> getWeekDays() {
    return [
      DropdownItem(label: lan.getTranslatedText('monday'), value: 1),
      DropdownItem(label: lan.getTranslatedText('tuesday'), value: 2),
      DropdownItem(label: lan.getTranslatedText('wednesday'), value: 3),
      DropdownItem(label: lan.getTranslatedText('thursday'), value: 4),
      DropdownItem(label: lan.getTranslatedText('friday'), value: 5),
      DropdownItem(label: lan.getTranslatedText('saturday'), value: 6),
      DropdownItem(label: lan.getTranslatedText('sunday'), value: 7),
    ];
  }
}
