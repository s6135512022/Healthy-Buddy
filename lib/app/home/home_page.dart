import 'dart:developer';

import 'package:cal_tracker1/app/home/recipes/recipes_page.dart';
import 'package:cal_tracker1/app/home/table/table_page.dart';
import 'package:flutter/material.dart';
import 'package:cal_tracker1/app/home/account/account_page.dart';
import 'package:cal_tracker1/app/home/cupertino_home_scaffold.dart';
import 'package:cal_tracker1/app/home/entries/entries_page.dart';
import 'package:cal_tracker1/app/home/jobs/jobs_page.dart';
import 'package:cal_tracker1/app/home/tab_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.jobs;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.jobs: GlobalKey<NavigatorState>(),
    TabItem.entries: GlobalKey<NavigatorState>(),
    TabItem.table: GlobalKey<NavigatorState>(),
    TabItem.recipes: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.jobs: (_) => JobsPage(),
      TabItem.entries: (context) => EntriesPage.create(context),
      TabItem.table: (_) => TablePage(),
      TabItem.recipes: (_) => RecipesPage(),
      TabItem.account: (_) => AccountPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
