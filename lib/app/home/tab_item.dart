import 'package:flutter/material.dart';

//แก้ลำดับการแสดงหน้าแรก
enum TabItem {
  jobs,
  entries,
  table,
  recipes,
  account,
}

class TabItemData {
  const TabItemData({@required this.title, @required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.jobs: TabItemData(title: 'Workouts', icon: Icons.fitness_center),
    TabItem.entries:
        TabItemData(title: 'Diaries', icon: Icons.collections_bookmark),
    TabItem.table:
        TabItemData(title: 'Calorie table', icon: Icons.calendar_today_rounded),
    TabItem.recipes: TabItemData(title: 'Recipes', icon: Icons.fastfood_sharp),
    TabItem.account: TabItemData(title: 'Me', icon: Icons.person),
  };
}
