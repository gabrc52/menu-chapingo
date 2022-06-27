import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:menu2018/models/constants.dart';
import 'package:menu2018/models/settings.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';
import 'screens/feedback.dart';
import 'screens/home.dart';

class MenuApp extends StatelessWidget {
  const MenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'MX')],
        title: 'Menú Chapingo',
        theme: settings.theme == SelectedTheme.system
            ? (UniversalPlatform.isIOS ? Themes.iosLight : Themes.androidLight)
            : themeFromSelectedTheme(settings.theme),
        darkTheme: settings.theme == SelectedTheme.system
            ? (UniversalPlatform.isIOS ? Themes.iosDark : Themes.androidDark)
            : null,
        home: child,
        routes: {
          '/feedback': (context) => const FeedbackPage(),
        },
      ),
      child: const HomePage(),
    );
  }
}
