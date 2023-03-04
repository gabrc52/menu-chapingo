import 'package:flutter/material.dart';
import 'package:menu2018/models/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

enum SelectedTheme {
  system,
  androidLight,
  androidDark,
  iosLight,
  iosDark,
  classicLight,
  classicDark
}

extension ParseToString on SelectedTheme {
  String string() {
    switch (this) {
      case SelectedTheme.system:
        return 'Usar tema del dispositivo';
      case SelectedTheme.androidLight:
        return 'Claro';
      case SelectedTheme.androidDark:
        return 'Oscuro';
      case SelectedTheme.iosLight:
        return 'Claro Apple';
      case SelectedTheme.iosDark:
        return 'Oscuro Apple';
      case SelectedTheme.classicLight:
        return 'Claro clásico';
      case SelectedTheme.classicDark:
        return 'Oscuro clásico';
      default:
        return 'Desconocido';
    }
  }

  int toInt() {
    int i = 0;
    for (SelectedTheme value in SelectedTheme.values) {
      if (value == this) {
        return i;
      }
      i++;
    }
    return 0;
  }
}

ThemeData themeFromSelectedTheme(SelectedTheme theme) {
  switch (theme) {
    case SelectedTheme.system:
      throw Error();
    case SelectedTheme.androidLight:
      return Themes.androidLight;
    case SelectedTheme.androidDark:
      return Themes.androidDark;
    case SelectedTheme.iosLight:
      return Themes.iosLight;
    case SelectedTheme.iosDark:
      return Themes.iosDark;
    case SelectedTheme.classicLight:
      return Themes.classicLight;
    case SelectedTheme.classicDark:
      return Themes.classicDark;
  }
}

SelectedTheme themeModeFromInt(int x) {
  try {
    return SelectedTheme.values[x];
  } catch (e) {
    return SelectedTheme.system;
  }
}

class Settings extends ChangeNotifier {
  Settings() {
    SharedPreferences.getInstance().then((prefs) {
      _theme = themeModeFromInt(prefs.getInt('theme') ?? 0);
      notifyListeners();
    });
  }

  SelectedTheme _theme = SelectedTheme.system;

  SelectedTheme get theme => _theme;

  set theme(SelectedTheme value) {
    _theme = value;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('theme', value.toInt());
    });
  }

  bool isIOSTheme() {
    if (theme == SelectedTheme.system) {
      return UniversalPlatform.isIOS;
    } else {
      return theme == SelectedTheme.iosDark || theme == SelectedTheme.iosLight;
    }
  }
}
