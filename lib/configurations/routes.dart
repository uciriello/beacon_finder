import 'package:flutter/material.dart';

import '../screens/homepage.dart';
import '../screens/settings.dart';

Map<String, Widget Function(BuildContext)> appRoutes =  <String, WidgetBuilder>{
  MyHomePage.routeName: (ctx) => MyHomePage(),
  SettingsPage.routeName: (ctx) => SettingsPage(),
};