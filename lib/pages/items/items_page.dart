import 'dart:convert';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:animated_tree_view/tree_view/widgets/expansion_indicator.dart';
import 'package:animated_tree_view/tree_view/widgets/indent.dart';
import 'package:flutter/material.dart';
import 'package:mplusanalyzer/models/counting_item.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/widgets/auto_sliding_text.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class ItemsPage extends StatefulWidget {
  ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  LanguagePack lan = LanguagePack();
  TreeNode treeNodeGroups = TreeNode();
  bool expandChildrenOnReady = true;
  List<CountingItem> listItem = [], filteredItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setItemList();
  }

  Future<void> setItemList() async {
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      'Countings/GetCountingItems',
      {},
    );
    if (response.code == 200) {
      List list_ = jsonDecode(response.message) as List;
      listItem = list_
          .map(
            (e) => CountingItem(
              mainGroup: e['mainGroup'],
              subGroup: e['subGroup'],
              itemCode: e['itemCode'],
              itemName: e['itemName'],
              quantityOnCar: 0,
              quantityTyped1: 0,
              quantityTyped2: 0,
              quantityTyped3: 0,
              quantityTyped4: 0,
              quantityTyped5: 0,
            ),
          )
          .toList();
    }
    setItemListFilterAndGroups('');
  }

  void setItemListFilterAndGroups(String filterKey_) {
    // order by
    String orderBy = GlobalParams.params.countingItemsOrderBy;
    if (orderBy == '0') {
      listItem.sort((a, b) => a.itemCode.compareTo(b.itemCode));
    } else {
      listItem.sort((a, b) => a.itemName.compareTo(b.itemName));
    }

    if (filterKey_.isEmpty) {
      filteredItems = listItem;
    } else {
      filteredItems = listItem.where((item) {
        final filter = filterKey_.toLowerCase();
        return item.itemCode.toLowerCase().contains(filter) ||
            item.itemName.toLowerCase().contains(filter);
      }).toList();
    }

    // Group items by mainGroup and subGroup
    treeNodeGroups.clear();
    final Map<String, Set<String>> groupMap = {};

    for (var item in filteredItems) {
      groupMap.putIfAbsent(item.mainGroup, () => <String>{});
      groupMap[item.mainGroup]!.add(item.subGroup);
    }

    groupMap.forEach((mainGroup, subGroups) {
      final mainGroupNode = TreeNode(key: mainGroup);
      if (!(subGroups.length == 1 && subGroups.first == '')) {
        for (var subGroup in subGroups) {
          if (subGroup.isNotEmpty) {
            mainGroupNode.add(TreeNode(key: subGroup));
          } else {
            mainGroupNode.add(
              TreeNode(key: lan.getTranslatedText('subGroupless')),
            );
          }
        }
      }

      treeNodeGroups.add(mainGroupNode);
    });
    setState(() {
      isLoading = false;
    });
  }

  // void updateFilterKey(String filterKey_) async {
  //   setItemListFilterAndGroups(filterKey_);
  //   // if (treeNodeGroups.children.isNotEmpty && filterKey_ != '') {
  //   //   List<CountingItem> listItemsByGroup = filteredItems
  //   //       .where(
  //   //         (e) =>
  //   //             (e.subGroup == ''
  //   //                 ? lan.getTranslatedText('subGroupless')
  //   //                 : e.subGroup) ==
  //   //             treeNodeGroups.childrenAsList[0].childrenAsList[0].key,
  //   //       )
  //   //       .toList();
  //   //   setItemModalSheet(listItemsByGroup);
  //  // }
  // }

  onItemTap(CountingItem item) async {
    Navigator.pop(context);
    Navigator.pop(context, item);
  }

  void setItemModalSheet(List<CountingItem>? listItems) async {
    if (listItems == null || listItems.isEmpty) {
      return;
    }
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
                    text:
                        listItems[0].mainGroup + ' - ' + listItems[0].subGroup,
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
                  child: ListView.separated(
                    itemCount: listItems.length + 1,
                    itemBuilder: (contextM, index) => index == listItems.length
                        ? SizedBox(height: 60)
                        : getWidgetItemCard(listItems[index]),
                    separatorBuilder: (context, index) => SizedBox(height: 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (context.mounted) {
      setState(() {});
    }
  }

  Widget getWidgetItemCard(CountingItem item) {
    return GestureDetector(
      onTap: () => onItemTap(item),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: Offset(2, 4), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          color: ThemeModule.cWhiteBlackColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                item.itemName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'poppins_semibold',
                  fontSize: 15,
                  color: ThemeModule.cBlackWhiteColor,
                ),
              ),
            ),
            SizedBox(height: 5),
            Widgets().getRichText(
              lan.getTranslatedText('code'),
              TextStyle(
                color: ThemeModule.cBlackWhiteColor,
                fontFamily: 'poppins_regular',
                fontSize: 13,
              ),
              item.itemCode,
              TextStyle(
                color: ThemeModule.cBlackWhiteColor,
                fontSize: 12,
                fontFamily: 'poppins_semibold',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getWidgetItemGroups(List<CountingItem> listItems) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 15),
      child: Container(
        padding: EdgeInsets.all(15),
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ThemeModule.cWhiteBlackColor,
        ),
        child: TreeView.simple(
          expansionBehavior: ExpansionBehavior.collapseOthers,
          tree: treeNodeGroups,
          showRootNode: false,
          expansionIndicatorBuilder: (context, node) =>
              ChevronIndicator.rightDown(tree: node, color: Colors.blue[700]),
          indentation: const Indentation(style: IndentStyle.roundJoint),
          onItemTap: (item) {
            if (item.level == 2) {
              String subGroupName =
                  item.key.toString() == lan.getTranslatedText('subGroupless')
                  ? ''
                  : item.key.toString();
              List<CountingItem> listItemsByGroup = listItems
                  .where((e) => e.subGroup == subGroupName)
                  .toList();
              setItemModalSheet(listItemsByGroup);
            } else if (item.level == 1 && item.children.isEmpty) {
              List<CountingItem> listItemsByGroup = listItems
                  .where((e) => e.mainGroup == item.key.toString())
                  .toList();
              setItemModalSheet(listItemsByGroup);
            }
          },
          builder: (context, node) => Column(
            children: [
              Container(
                height: 20,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(node.key),
                ),
              ),
              Divider(),
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
        child: AppBarForItems(onFilterKeyChanged: setItemListFilterAndGroups),
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            repeat: ImageRepeat.noRepeat,
          ),
        ),
        child: !isLoading
            ? filteredItems.length > 0
                  ? getWidgetItemGroups(filteredItems)
                  : Widgets().getEmptyDataWidget()
            : Widgets().getLoadingWidget(context),
      ),
    );
  }
}

class AppBarForItems extends StatefulWidget {
  final Function(String) onFilterKeyChanged;
  const AppBarForItems({super.key, required this.onFilterKeyChanged});

  @override
  State<AppBarForItems> createState() => _AppBarForItemsState();
}

class _AppBarForItemsState extends State<AppBarForItems> {
  LanguagePack lan = LanguagePack();
  bool isSearching = false;
  TextEditingController txtSearchController = TextEditingController();

  void _onSearchChanged(String query) {
    widget.onFilterKeyChanged(query);
  }

  @override
  Widget build(BuildContext context) {
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
                _onSearchChanged('');
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
                      lan.getTranslatedText('items'),
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
                () => _onSearchChanged(txtSearchController.text),
              ),
      ),
    );
  }
}
