import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TabInfo> tabs;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: tabs.map((tab) {
        return BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.title);
      }).toList(),
    );
  }
}

class TabInfo {
  final String title;
  final IconData icon;

  const TabInfo(this.title, this.icon);
}
