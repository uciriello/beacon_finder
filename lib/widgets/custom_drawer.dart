import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/global_translations_provider.dart';
import '../providers/auth_provider.dart';

import '../screens/settings.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mario Rossi',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text(translations.text('pageNames.settings')),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(SettingsPage.routeName);
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text(translations.text('pages.settings.exit')),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/');
                          Provider.of<AuthProvider>(context, listen: false)
                              .logout();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
