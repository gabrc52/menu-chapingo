import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'defaults.dart';
import 'info.dart';
import 'package:http/http.dart' as http;

DateTime truncateDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

DateTime get today {
  final now = DateTime.now();
  return truncateDate(now);
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
  DateTime _fecha = today;

  /// Si debería comportarse como la versión anterior:
  ///
  /// Un día antes del día 1 es como el día 1
  ///
  /// Esto no debería ser así pero es para mantener compatibilidad con la versión anterior hasta que se actualicen
  bool legacy = Defaults.legacy;

  /// Se asegura que la fecha no tenga hora
  DateTime get fecha => _fecha;

  set fecha(DateTime date) => _fecha = truncateDate(date);

  int _fechaADiaDelCiclo(DateTime fecha) {
    if (legacy && fecha.isAtSameMomentAs(inicio)) {
      if (menu['0'] != null) {
        return 0;
      } else {
        return 1;
      }
    }

    /// If this is not consistent and one is UTC and one isn't this leads to off-by-one bugs!
    /// All dates are now in UTC to fix the bug.
    assert(fecha.isUtc);
    assert(_inicio.isUtc);
    return fecha.difference(_inicio).inDays % 56 + 1;
  }

  int get diaDelCiclo => _fechaADiaDelCiclo(fecha);

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

  bool get isToday => fecha.difference(today).inDays == 0;

  bool _noAlimentos(DateTime fecha) =>
      fecha.isAfter(fin) || fecha.isBefore(inicio);

  bool get noAlimentos => _noAlimentos(fecha);

  List<String?> getMenu(DateTime fecha, int alimento) {
    if (noAlimentos) throw NoAlimentosException();
    var menuActual = <String?>[]; // ignore: prefer_final_locals
    menu['${_fechaADiaDelCiclo(fecha)}'][alimento]
        .forEach((dynamic element) => menuActual.add(element));
    return menuActual;
  }

  List<String?> currentMenu(int alimento) {
    return getMenu(fecha, alimento);
  }

  String getTitle() {
    if (noAlimentos) return 'Menú Chapingo';
    return (today == fecha)
        ? 'Menú de hoy'
        : '${dias[fecha.weekday - 1]} ${fecha.day}/${meses[fecha.month - 1]}';
  }

  String menuAsString({required DateTime from, required DateTime to}) {
    from = truncateDate(from);
    to = truncateDate(to);
    final menu = StringBuffer();
    for (DateTime date = from;
        !date.isAtSameMomentAs(to);
        date = date.add(const Duration(days: 1))) {
      if (_noAlimentos(date)) continue; //TODO: display something
      menu.writeln(
          '${dias_completos[date.weekday - 1]} ${date.day}/${meses[date.month - 1]}:');
      for (int alimento = 0; alimento < 3; alimento++) {
        menu.write('  ${Alimento.values[alimento]}: ');
        menu.write(getMenu(date, alimento)[Componente.principal]);
        menu.write('; ');
        menu.writeln(getMenu(date, alimento)[Componente.postre]);
      }
      menu.writeln();
    }
    menu.write(
        'Enviado con Menú Chapingo, descárgalo en https://menu-chapingo.web.app/dl.html');
    return menu.toString();
  }

  Info? get everydayInfo => Info.fromJson(info['*']);

  Info? get currentInfo =>
      Info.fromJson(info['${fecha.year.toString().padLeft(4, '0')}'
          '${fecha.month.toString().padLeft(2, '0')}'
          '${fecha.day.toString().padLeft(2, '0')}']);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('menu') != null) &&
        ((prefs.getInt('lastUpdate_Menu') ?? 0) > Defaults.lastUpdateMenu)) {
      menu = json.decode(prefs.getString('menu')!);
    }
    if ((prefs.getInt('iDay') != null &&
            prefs.getInt('iMonth') != null &&
            prefs.getInt('iDay') != null &&
            prefs.getInt('fYear') != null &&
            prefs.getInt('fMonth') != null &&
            prefs.getInt('fDay') != null) &&
        ((prefs.getInt('lastUpdate_Fechas') ?? 0) >
            Defaults.lastUpdateFechas)) {
      inicio = DateTime.utc(
        prefs.getInt('iYear')!,
        prefs.getInt('iMonth')!,
        prefs.getInt('iDay')!,
      );
      fin = DateTime.utc(
        prefs.getInt('fYear')!,
        prefs.getInt('fMonth')!,
        prefs.getInt('fDay')!,
      );

      /// See [legacy]
      if (prefs.getBool('legacy') != null) {
        legacy = prefs.getBool('legacy')!;
      }
    }
    if ((prefs.getString('info') != null) &&
        ((prefs.getInt('lastUpdate_Info') ?? 0) > Defaults.lastUpdateInfo)) {
      info = json.decode(prefs.getString('info')!);
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
      inicio = DateTime.utc(
          inicioNuevo['year'], inicioNuevo['month'], inicioNuevo['day']);
      final Map finNuevo = fechas['fin'];
      fin = DateTime.utc(finNuevo['year'], finNuevo['month'], finNuevo['day']);
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

// Update code to use https://docs.flutter.dev/cookbook/networking/fetch-data? Maybe
Future<dynamic> _getJson(String file) async {
  //final httpClient = HttpClient();
  final uri =
      use_https ? Uri.https(data_url, '/$file') : Uri.http(data_url, '/$file');
  //final request = await httpClient.getUrl(uri);
  //final response = await request.close();
  final response = await http.get(uri);
  //final responseBody = await response.transform(utf8.decoder).join();
  final responseBody = utf8.decode(response.bodyBytes);
  return json.decode(responseBody);
}
