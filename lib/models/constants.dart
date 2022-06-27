import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const data_url = 'menu-chapingo.firebaseapp.com';

const use_https = true;

const meses = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic'
];

const dias = <String>['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const dias_completos = <String>[
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo'
];

class NoAlimentosException implements Exception {}

class Alimento {
  Alimento._();
  static const desayuno = 0;
  static const comida = 1;
  static const cena = 2;
  static const values = ['Desayuno', 'Comida', 'Cena'];
}

class Componente {
  Componente._();
  static const principal = 2;
  static const postre = 7;
}

class Themes {
  static final iosLight = ThemeData(
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
  );

  static final androidLight = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      accentColor: Colors.orangeAccent,
      primarySwatch: Colors.blueGrey,
    ),
    accentColor: Colors.orangeAccent,
  );

  static final iosDark = ThemeData(
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
  );

  static final androidDark = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      accentColor: Colors.orangeAccent,
      brightness: Brightness.dark,
    ),
    accentColor: Colors.orangeAccent,
  );
}
