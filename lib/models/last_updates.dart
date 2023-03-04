import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class LastUpdates {
  final String app;
  final String menu;
  final String avisos;
  final String fechas;

  const LastUpdates(
      {required this.app,
      required this.menu,
      required this.avisos,
      required this.fechas});
}

/// Gets the last updates for the app
/// Returns date strings as opposed to dates
class LastUpdate {
  static const String unknownLastUpdate = '??';

  static String intToDateStr(int n) {
    final string = n.toString();
    return '${string.substring(6, 8)}/${meses[int.parse(string.substring(4, 6)) - 1]}/${string.substring(0, 4)} (${int.parse(string.substring(8, 10))})';
  }

  static Future<String> app() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final lastUpdated = int.parse(packageInfo.buildNumber);
      return intToDateStr(lastUpdated);
    } catch (e) {
      return unknownLastUpdate;
    }
  }

  static Future<String> _lastUpdateFromPrefs(String prefsKey) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getInt(prefsKey);
    if (lastUpdated == null) {
      return unknownLastUpdate;
    } else {
      return intToDateStr(lastUpdated);
    }
  }

  static Future<String> avisos() async {
    return await _lastUpdateFromPrefs('lastUpdate_Info');
  }

  static Future<String> menu() async {
    return await _lastUpdateFromPrefs('lastUpdate_Menu');
  }

  static Future<String> fechas() async {
    return await _lastUpdateFromPrefs('lastUpdate_Fechas');
  }

  static Future<LastUpdates> getAll() async {
    return LastUpdates(
      app: await app(),
      menu: await menu(),
      avisos: await avisos(),
      fechas: await fechas(),
    );
  }
}
