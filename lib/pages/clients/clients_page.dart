import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mplusanalyzer/models/client.dart';
import 'package:mplusanalyzer/models/document_items.dart';
import 'package:mplusanalyzer/pages/clients/client_extra.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import '../confront/confront_extra.dart';

class ClientsPage extends StatefulWidget {
  final DocumentItems documentItems;
  final List<Client> listClient;
  final String sellersSelected;
  final int module;
  const ClientsPage(
    this.documentItems,
    this.listClient,
    this.sellersSelected,
    this.module, {
    super.key,
  });

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  LanguagePack lan = LanguagePack();
  List<String> listSellers = [];
  List<ClientGroupFilters> listClientGroupFilters = [];
  List<Client> listClients = [];
  int viewMode = 0;
  bool isLoading = true;
  String searchKey = '', filterKey = 'all';

  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(
      40.40574001660433,
      49.84338359773869,
    ), // Default if no clients
    zoom: 10.0, // World view zoom
  );

  @override
  void initState() {
    _initState();
    super.initState();
  }

  bool getStatus(Client client) {
    if (widget.module == 0) {
      return client.statusConfront == 0 ? false : true;
    } else if (widget.module == 1) {
      return client.statusFaq == 0 ? false : true;
    } else if (widget.module == 2) {
      return client.statusBmk == 0 ? false : true;
    }
    return false;
  }

  String getLastDocDate(Client client) {
    if (widget.module == 0) {
      return client.lastConfrontDate;
    } else if (widget.module == 1) {
      return client.lastFaqDate;
    } else if (widget.module == 2) {
      return client.lastBenchmarkDate;
    }
    return '';
  }

  Future<void> _initState() async {
    listSellers.add('all');
    List<String> listSellers_ = widget.sellersSelected.split(',');
    listSellers.addAll(listSellers_);

    listClientGroupFilters.add(
      ClientGroupFilters(
        id: 0,
        name: lan.getTranslatedText('list'),
        active: viewMode == 0 ? true : false,
      ),
    );
    listClientGroupFilters.add(
      ClientGroupFilters(
        id: 1,
        name: lan.getTranslatedText('map'),
        active: viewMode == 1 ? true : false,
      ),
    );

    setClientList();
  }

  Future<void> setClientList() async {
    listClients = [];
    List<Client> listClients_ = widget.listClient;

    if (listClients_.isNotEmpty) {
      listClients = listClients_
          .where(
            (e) =>
                e.clientName.toLowerCase().contains(searchKey.toLowerCase()) ||
                e.clientCode.contains(searchKey),
          )
          .toList();

      _loadClientMarkers();
    }

    setState(() {
      isLoading = false;
    });
  }

  void updateFilterKey(String searchKey_, String selectedAgent_) {
    setState(() {
      isLoading = true;
    });
    searchKey = searchKey_;
    filterKey = selectedAgent_;
    setClientList();
  }

  void setClientGroup(int viewMode_) {
    setState(() {
      isLoading = true;
    });
    viewMode = viewMode_;
    listClientGroupFilters.forEach((e) {
      if (e.id == viewMode) {
        e.active = true;
      } else {
        e.active = false;
      }
    });
    setClientList();
  }

  // for Map
  void _loadClientMarkers() {
    _markers.clear();
    for (Client client in listClients) {
      if (client.clientLongitude > 0 && client.clientLongitude > 0) {
        final marker = Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(
            getStatus(client)
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
          markerId: MarkerId(client.clientCode), // Unique ID for each marker
          position: LatLng(client.clientLatitude, client.clientLongitude),
          infoWindow: InfoWindow(
            title: client.clientName,
            snippet:
                '${lan.getTranslatedText('distance')}: ${client.distance.toStringAsFixed(2)}km        ${lan.getTranslatedText('debt')}: ${client.clientDebt}₼',
            onTap: () => _showContextMenu(context, client),
          ),
          onTap: () {},
        );
        _markers.add(marker);
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitAllMarkers();
  }

  Future<void> _fitAllMarkers() async {
    if (mapController == null || _markers.isEmpty) return;

    LatLngBounds bounds;
    if (_markers.length == 1) {
      final marker = _markers.first.position;
      bounds = LatLngBounds(
        southwest: LatLng(marker.latitude - 0.01, marker.longitude - 0.01),
        northeast: LatLng(marker.latitude + 0.01, marker.longitude + 0.01),
      );
    } else {
      double minLat = double.infinity, maxLat = -double.infinity;
      double minLon = double.infinity, maxLon = -double.infinity;

      for (var marker in _markers) {
        minLat = min(minLat, marker.position.latitude);
        maxLat = max(maxLat, marker.position.latitude);
        minLon = min(minLon, marker.position.longitude);
        maxLon = max(maxLon, marker.position.longitude);
      }

      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLon),
        northeast: LatLng(maxLat, maxLon),
      );
    }

    final padding = MediaQuery.of(context).size.width * 0.1; // 10% padding
    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }
  ///////////////

  void _showContextMenu(BuildContext context, Client client) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    Size size_ = MediaQuery.of(context).size;
    Offset offset_ = Offset(size_.width / 2, size_.height / 2);
    await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        offset_ & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          onTap: () {
            widget.documentItems.client = client;
            Navigator.pop(context);
          },
          child: Center(child: Text(lan.getTranslatedText('choose'))),
        ),
        PopupMenuItem<String>(
          onTap: () {
            Utils().openNavigationApp(
              '${client.clientLatitude},${client.clientLongitude}',
            );
          },
          child: Center(child: Text(lan.getTranslatedText('route'))),
        ),
        PopupMenuItem<String>(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ClientExtraPage(client.clientCode, client.clientName),
              ),
            );
          },
          child: Center(child: Text(lan.getTranslatedText('extra'))),
        ),
      ],
      elevation: 8.0,
    );
  }

  Widget getWidgetClientCard(Client client) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Slidable(
        closeOnScroll: true,
        startActionPane: ActionPane(
          extentRatio: 0.6,
          motion: const ScrollMotion(),
          children: [
            Widgets().getSlideElement(
              'clientExtra',
              Icons.speaker_notes,
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ClientExtraPage(client.clientCode, client.clientName),
                  ),
                );
              },
              Colors.lightBlueAccent,
            ),
            Widgets().getSlideElement(
              'clientConfronts',
              Icons.notes_rounded,
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ConfrontExtra(client.clientCode, client.clientName),
                  ),
                );
              },
              Colors.lightGreenAccent,
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            SizedBox(width: 2),

            SlidableAction(
              autoClose: true,
              borderRadius: BorderRadius.circular(20),
              onPressed: (_) => Utils().openNavigationApp(
                '${client.clientLatitude},${client.clientLongitude}',
              ),
              backgroundColor: Colors.lightBlue,
              foregroundColor: ThemeModule.cBlackWhiteColor,
              icon: Icons.navigation_outlined,
              label: lan.getTranslatedText('route'),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              spacing: 2,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            widget.documentItems.client = client;
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: ThemeModule.cWhiteBlackColor,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
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
                    color: getStatus(client)
                        ? ThemeModule.cGreenColor
                        : ThemeModule.cForeColor,
                    border: Border.all(
                      width: 1,
                      color: ThemeModule.cWhiteBlackColor,
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 6,
                      left: 6,
                      top: 6,
                      right: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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

                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Widgets().getRichText(
                                lan.getTranslatedText('code'),
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_reguler',
                                  fontSize: 12,
                                ),
                                client.clientCode,
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_semibold',
                                  fontSize: 10,
                                ),
                              ),
                              Widgets().getRichText(
                                lan.getTranslatedText('name'),
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_reguler',
                                  fontSize: 12,
                                ),
                                client.clientName,
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_semibold',
                                  fontSize: 10,
                                ),
                              ),

                              Widgets().getRichText(
                                lan.getTranslatedText('seller'),
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_reguler',
                                  fontSize: 12,
                                ),
                                client.seller,
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_semibold',
                                  fontSize: 10,
                                ),
                              ),
                              Widgets().getRichText(
                                lan.getTranslatedText('lastDocDate'),
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_reguler',
                                  fontSize: 12,
                                ),
                                getLastDocDate(client),
                                TextStyle(
                                  color: ThemeModule.cWhiteBlackColor,
                                  fontFamily: 'poppins_semibold',
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 150,
                            child: Widgets().getRichText(
                              lan.getTranslatedText('distance'),
                              TextStyle(
                                color: ThemeModule.cBlackWhiteColor,
                                fontFamily: 'poppins_reguler',
                                fontSize: 12,
                              ),
                              client.distance.toStringAsFixed(2) + 'km',
                              TextStyle(
                                color: Colors.red,
                                fontFamily: 'poppins_semibold',
                                fontSize: 10,
                              ),
                            ),
                          ),

                          Container(
                            width: 100,
                            child: Widgets().getRichText(
                              lan.getTranslatedText('debt'),
                              TextStyle(
                                color: ThemeModule.cBlackWhiteColor,
                                fontFamily: 'poppins_reguler',
                                fontSize: 12,
                              ),
                              client.clientDebt.toStringAsFixed(2) + '₼',
                              TextStyle(
                                color: Colors.red,
                                fontFamily: 'poppins_semibold',
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Center(
                            child: Text(
                              client.clientName,
                              style: TextStyle(
                                color: ThemeModule.cBlackWhiteColor,
                                fontSize: 12,
                                fontFamily: 'poppins_medium',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getWidgetClientGroupButtonItem(int viewMode_, void Function() onTap) {
    ClientGroupFilters fltr = listClientGroupFilters[viewMode_];
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: fltr.active ? ThemeModule.cForeColor : null,
          ),
          child: Center(
            child: Text(
              fltr.name,
              style: TextStyle(
                fontFamily: 'poppins_medium',
                fontSize: 14,
                color: fltr.active ? ThemeModule.cWhiteBlackColor : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getWidgetClientGroupButtons() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(39),
        color: ThemeModule.cWhiteBlackColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            getWidgetClientGroupButtonItem(0, () => setClientGroup(0)),
            getWidgetClientGroupButtonItem(1, () => setClientGroup(1)),
          ],
        ),
      ),
    );
  }

  Widget getMapOfClientLocations() {
    return Container(
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        compassEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }

  Widget getListOfClients() {
    return listClients.length > 0
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              if (index == listClients.length) {
                return SizedBox(height: 40);
              } else {
                return getWidgetClientCard(listClients[index]);
              }
            },
            itemCount: listClients.length + 1,
          )
        : Widgets().getEmptyDataWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBarForClient(
          selectedAgent: filterKey,
          listSellers: listSellers,
          onFilterKeyChanged: updateFilterKey,
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/main_background.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              repeat: ImageRepeat.noRepeat,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                child: Column(
                  children: [
                    getWidgetClientGroupButtons(),
                    SizedBox(height: 5),
                    Expanded(
                      child: !isLoading
                          ? viewMode == 0
                                ? getListOfClients()
                                : getMapOfClientLocations()
                          : Widgets().getLoadingWidget(context),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 20,
                right: 20,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ThemeModule.cContainerInfoColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        lan.getTranslatedText('countOfClients') +
                            ': ' +
                            widget.listClient.length.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarForClient extends StatefulWidget {
  final String selectedAgent;
  final List<String> listSellers;
  final Function(String, String) onFilterKeyChanged;
  const AppBarForClient({
    super.key,
    required this.selectedAgent,
    required this.listSellers,
    required this.onFilterKeyChanged,
  });

  @override
  State<AppBarForClient> createState() => _AppBarForClientState();
}

class _AppBarForClientState extends State<AppBarForClient> {
  LanguagePack lan = LanguagePack();
  ThemeModule themeModule = ThemeModule();
  bool isSearching = false;
  TextEditingController txtSearchController = TextEditingController();
  List listSellers = [];

  void _onSearchChanged(String query, String selectedAgent) {
    widget.onFilterKeyChanged(query, selectedAgent);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listSellers = widget.listSellers;
    return ClipRRect(
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
                _onSearchChanged('', widget.selectedAgent);
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
                        color: widget.selectedAgent == 'all'
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
                  primary:
                      false, // Prevents this internal ListView from conflicting
                  physics:
                      const ClampingScrollPhysics(), // Allows it to scroll internally
                  shrinkWrap: true,
                  itemCount: listSellers.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) => MenuItemButton(
                    onPressed: () => setState(() {
                      _onSearchChanged(
                        txtSearchController.text,
                        listSellers[index],
                      );
                    }),
                    child: Text(
                      lan.getTranslatedText(listSellers[index]),
                      style: TextStyle(
                        fontFamily: widget.selectedAgent == listSellers[index]
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
                      'M+ Analyzer',
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
                () => _onSearchChanged(
                  txtSearchController.text,
                  widget.selectedAgent,
                ),
              ),
      ),
    );
  }
}

class ClientGroupFilters {
  late int id;
  late String name;
  late bool active;
  ClientGroupFilters({
    required this.id,
    required this.name,
    required this.active,
  });
}
