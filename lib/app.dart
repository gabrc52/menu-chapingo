import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/feedback.dart';
import 'screens/home.dart';

class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('es', 'MX')],
      title: 'Menú Chapingo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.orangeAccent,
        brightness: Brightness.light,
      ),
      home: HomePage(),
      routes: {
        '/feedback': (context) => FeedbackPage(),
      },
    );
  }
}
