import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'defaults.dart';
import 'info.dart';

DateTime get _today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class AppState {
  Map<String, dynamic> menu = Defaults.menu;
  Map<String, dynamic> info = Defaults.info;
  DateTime _inicio = Defaults.inicio;

  DateTime get inicio {
    if (legacy) return _inicio.add(const Duration(days: -1));
    return _inicio;
  }

  set inicio(DateTime newValue) => _inicio = newValue;

  DateTime fin = Defaults.fin;
  DateTime _fecha = _today;

  /// Si debería comportarse como la versión anterior:
  ///
  /// Un día antes del día 1 es como el día 1
  ///
  /// Esto no debería ser así pero es para mantener compatibilidad con la versión anterior hasta que se actualicen
  bool legacy = Defaults.legacy;

  DateTime get fecha => _fecha;
  set fecha(DateTime date) =>
      _fecha = DateTime(date.year, date.month, date.day);

  int get _diaDelCiclo {
    if (legacy && fecha.isAtSameMomentAs(inicio)) {
      if (menu['0'] != null) {
        return 0;
      } else {
        return 1;
      }
    }
    return fecha.difference(_inicio).inDays % 56 + 1;
  }

  void goToDate(DateTime date) {
    fecha = date;
  }

  void incrementDate() {
    goToDate(fecha.add(const Duration(days: 1)));
  }

  void decrementDate() {
    goToDate(fecha.add(const Duration(days: -1)));
  }

  void goToToday() {
    goToDate(DateTime.now());
  }

  bool get canIncrement => fecha.isBefore(fin);
  bool get canDecrement => fecha.isAfter(inicio);
  bool get isToday => fecha.difference(_today).inDays == 0;

  bool get noAlimentos => fecha.isAfter(fin) || fecha.isBefore(inicio);

  List<String> currentMenu(int alimento) {
    if (noAlimentos) throw NoAlimentosException();
    var menuActual = <String>[]; // ignore: prefer_final_locals
    menu['$_diaDelCiclo'][alimento]
        .forEach((dynamic element) => menuActual.add(element));
    return menuActual;
  }

  String getTitle() {
    if (noAlimentos) return 'Menú Chapingo';
    return (_today == fecha)
        ? 'Hoy (Día $_diaDelCiclo)'
        : '${dias[fecha.weekday - 1]} ${fecha.day}/${meses[fecha.month - 1]}'
        ' (Día $_diaDelCiclo)';
  }

  Info get everydayInfo => Info.fromJson(info['*']);

  Info get currentInfo =>
      Info.fromJson(info['${fecha.year.toString().padLeft(4, '0')}'
          '${fecha.month.toString().padLeft(2, '0')}'
          '${fecha.day.toString().padLeft(2, '0')}']);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('menu') != null) &&
        ((prefs.getInt('lastUpdate_Menu') ?? 0) > Defaults.lastUpdateMenu)) {
      menu = json.decode(prefs.getString('menu'));
    }
    if ((prefs.getInt('iDay') != null) &&
        ((prefs.getInt('lastUpdate_Fechas') ?? 0) > Defaults.lastUpdateFechas)) {
      inicio = DateTime(
        prefs.getInt('iYear'),
        prefs.getInt('iMonth'),
        prefs.getInt('iDay'),
      );
      fin = DateTime(
        prefs.getInt('fYear'),
        prefs.getInt('fMonth'),
        prefs.getInt('fDay'),
      );

      /// See [legacy]
      if (prefs.getBool('legacy') != null) {
        legacy = prefs.getBool('legacy');
      }
    }
    if ((prefs.getString('info') != null) &&
        ((prefs.getInt('lastUpdate_Info') ?? 0) > Defaults.lastUpdateInfo)) {
      info = json.decode(prefs.getString('info'));
    }
  }

  Future<void> update() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> updates = await _getJson('updates.json');
    if (updates['menu'] > (prefs.getInt('lastUpdate_Menu') ?? 0)) {
      menu = await _getJson('menu.json');
      prefs.setString('menu', json.encode(menu));
      prefs.setInt('lastUpdate_Menu', updates['menu']);
    }
    if (updates['fechas'] > (prefs.getInt('lastUpdate_Fechas') ?? 0)) {
      final Map<String, dynamic> fechas = await _getJson('fechas.json');
      final Map inicioNuevo = fechas['inicio'];
      inicio = DateTime(
          inicioNuevo['year'], inicioNuevo['month'], inicioNuevo['day']);
      final Map finNuevo = fechas['fin'];
      fin = DateTime(finNuevo['year'], finNuevo['month'], finNuevo['day']);
      prefs.setInt('iYear', _inicio.year);
      prefs.setInt('iMonth', _inicio.month);
      prefs.setInt('iDay', _inicio.day);
      prefs.setInt('fYear', fin.year);
      prefs.setInt('fMonth', fin.month);
      prefs.setInt('fDay', fin.day);
      prefs.setInt('lastUpdate_Fechas', updates['fechas']);
      legacy = fechas['legacy'] ?? false;
      prefs.setBool('legacy', legacy);
    }
    if (updates['info'] > (prefs.getInt('lastUpdate_Info') ?? 0)) {
      info = await _getJson('info.json');
      prefs.setString('info', json.encode(info));
      prefs.setInt('lastUpdate_Info', updates['info']);
    }
  }
}

Future<dynamic> _getJson(String file) async {
  final httpClient = HttpClient();
  final uri =
      use_https ? Uri.https(data_url, '/$file') : Uri.http(data_url, '/$file');
  final request = await httpClient.getUrl(uri);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  return json.decode(responseBody);
}
