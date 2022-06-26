import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:universal_platform/universal_platform.dart';
import 'screens/feedback.dart';
import 'screens/home.dart';

class MenuApp extends StatelessWidget {
  const MenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'MX')],
      title: 'Menú Chapingo',
      theme: UniversalPlatform.isIOS
          ? ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: ThemeData.light().canvasColor,
                foregroundColor: Colors.black87,
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 20,
                ),
                actionsIconTheme: const IconThemeData(
                  color: CupertinoColors.activeBlue,
                ),
                centerTitle: false,
                surfaceTintColor: Colors.blue,
                toolbarTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                elevation: 0,
              ),
            )
          : ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                accentColor: Colors.orangeAccent,
                primarySwatch: Colors.blueGrey,
              ),
              accentColor: Colors.orangeAccent,
            ),
      darkTheme: UniversalPlatform.isIOS
          ? ThemeData(
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                backgroundColor: CupertinoColors.black,
                elevation: 0,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
                centerTitle: false,
                actionsIconTheme: IconThemeData(
                  color: CupertinoColors.activeBlue,
                ),
                surfaceTintColor: Colors.blue,
              ),
              canvasColor: CupertinoColors.black,
              accentColor: CupertinoColors.activeBlue,

              // brightness: Brightness.dark,
            )
          : ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                accentColor: Colors.orangeAccent,
                brightness: Brightness.dark,
              ),
              accentColor: Colors.orangeAccent,
            ),
      home: const HomePage(),
      routes: {
        '/feedback': (context) => const FeedbackPage(),
      },
    );
  }
}
