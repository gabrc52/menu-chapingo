import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'screens/feedback.dart';
import 'screens/home.dart';

class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [Locale('es', 'MX')],
      title: 'Menú Chapingo',
      theme: platformThemeData(
        context,
        material: (data) => ThemeData(
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.orangeAccent,
          brightness: Brightness.light,
        ),
        cupertino: (data) => ThemeData(
          appBarTheme: const AppBarTheme(
            centerTitle: false,
          ),
        ),
      ),
      darkTheme: platformThemeData(
        context,
        material: (data) => ThemeData(
          accentColor: Colors.orangeAccent,
          brightness: Brightness.dark,
        ),
        cupertino: (data) => ThemeData.dark(
          
        ),
      ),
      home: HomePage(),
      routes: {
        '/feedback': (context) => FeedbackPage(),
      },
    );
  }
}
