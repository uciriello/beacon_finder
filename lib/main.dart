import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/global_translations_provider.dart';
import 'providers/auth_provider.dart';

import 'configurations/base_theme.dart';
import 'configurations/routes.dart';
import 'configurations/app_providers.dart';

import 'screens/homepage.dart';
/*import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';*/

Future<void> _initInternationalization() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<String> supportedLanguages = ["en", "it"];
  await translations.init(supportedLanguages, fallbackLanguage: 'en');
}


void main() async {
  await _initInternationalization();
  return runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      // third argument of Consumer builder is child and is the static part you don't want to rebuild
      child: Consumer2<GlobalTranslationsProvider, AuthProvider>(
        builder: (ctx, lang, auth, _) => MaterialApp(
          locale: lang.locale ?? translations.locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: translations.supportedLocales(),
          title: 'Flutter Demo Localization',
          theme: BaseThemeData().baseTheme,
          routes: appRoutes,
          home: MyHomePage()
          /*auth.isAuth
              ? MyHomePage()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),*/
        ),
      ),
    );
  }
}
