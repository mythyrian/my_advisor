import 'package:flutter/material.dart';
import 'package:my_advisor/pages/history.dart';
import 'package:my_advisor/pages/review.dart';
import 'package:my_advisor/constant/color.dart';
import 'package:my_advisor/pages/setting.dart';
import 'package:my_advisor/widgets/bottombar_item.dart';

import 'home.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int _activeTab = 0;

  final List _barItems = [
    {
      "icon": Icons.map_outlined,
      "active_icon": Icons.map_rounded,
      "page": HomePage(),
    },
    {
      "icon": Icons.rate_review_outlined,
      "active_icon": Icons.rate_review_rounded,
      "page": ReviewPage(),
    },
    {
      "icon": Icons.location_history_outlined,
      "active_icon": Icons.location_history_rounded,
      "page": HistoryPage(),
    },
    {
      "icon": Icons.settings_outlined,
      "active_icon": Icons.settings_rounded,
      "page": SettingPage(),
    },
  ];

  @override
  Widget build(BuildContext context) { //questo widget builda tutta la pagina
    return Scaffold(
      backgroundColor: Color(AppColor.appBgColor),
      body: _buildPage(),
      floatingActionButton: _buildBottomBar(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildPage() { // crea le pagine history,setting,review  e home
    return IndexedStack(
      index: _activeTab,
      children: List.generate(
        _barItems.length,
        (index) => _barItems[index]["page"],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 55,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Color(AppColor.bottomBarColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(AppColor.shadowColor).withOpacity(0.1),
            blurRadius: 1,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          _barItems.length,
          (index) => BottomBarItem(
            _activeTab == index
                ? _barItems[index]["active_icon"]
                : _barItems[index]["icon"],
            isActive: _activeTab == index,
            activeColor: Color(AppColor.primary ),
            onTap: () {
              setState(() {
                _activeTab = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
