import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants.dart';
import '../state_container.dart';
import '../models.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// https://stackoverflow.com/questions/57937280/how-can-i-detect-if-my-flutter-app-is-running-in-the-web

//TODO: should be refactored

class MenuBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    return PopupMenuButton<Opciones>(
      tooltip: 'Menú',
      onSelected: (Opciones choice) async {
        switch (choice) {
          case Opciones.actualizar:
            container?.showRefreshIndicatorAndUpdate();
            break;
          case Opciones.compartir:
            Share.share(
                'Descarga Menú Chapingo, la nueva app para ver el menú de la UACh: https://menu-chapingo.web.app/dl.html');
            break;
          case Opciones.acerca:
            String intToDateStr(int n) {
              final String _string = n.toString();
              return '${_string.substring(6, 8)}/${meses[int.parse(_string.substring(4, 6)) - 1]}/${_string.substring(0, 4)} (${int.parse(_string.substring(8, 10))})';
            }
            final prefs = await SharedPreferences.getInstance();
            int lastUpdated;
            try {
              final packageInfo = await PackageInfo.fromPlatform();
              lastUpdated = int.parse(packageInfo.buildNumber);
            } catch (e) {
              lastUpdated = 9999999999;
            }
            final avisos = prefs.getInt('lastUpdate_Info');
            final menu = prefs.getInt('lastUpdate_Menu');
            final semestre = prefs.getInt('lastUpdate_Fechas');
            showAboutDialog(
              context: context,
              applicationName: 'Menú Chapingo',
              applicationVersion: 'La mejor app para ver el menú',
              applicationIcon: const Icon(Icons.restaurant_menu),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      /// TODO: update this with App Store link once available.
                      /// Remember: Apple disallows any mentions of Android or Play Store
                      if (!Platform.isIOS)
                        ListTile(
                            title: const Text('Google Play'),
                            subtitle: const Text(
                                'Si te gusta la app, danos 5 estrellas 😉, o comparte tu opinión'),
                            leading:
                                const Icon(Icons.shop, color: Colors.green),
                            onTap: () async {
                              const String playStoreSchemeUrl =
                                  'market://details?id=com.gabo.menu2018';
                              const String playStoreWebUrl =
                                  'https://play.app.goo.gl/?link=https://play.google.com/store/apps/details?id=com.gabo.menu2018';
                              try {
                                launchUrl(Uri.parse(playStoreSchemeUrl),
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                launchUrl(Uri.parse(playStoreWebUrl),
                                    mode: LaunchMode.externalApplication);
                              }
                            }),
                      ListTile(
                        title: const Text('Página de Facebook'),
                        subtitle: const Text('No olvides dejar tu like 😉'),
                        onTap: () async {
                          //analytics.logEvent(name: 'fb');
                          const String iosUrl = 'fb://profile/214398592630533';
                          const String url =
                              'https://www.facebook.com/menuchapingo/';
                          if (Platform.isIOS || Platform.isMacOS) {
                            try {
                              launchUrl(Uri.parse(iosUrl));
                            } catch (e) {
                              launchUrl(Uri.parse(url));
                            }
                          } else {
                            launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        leading: const Icon(
                          IconData(0xf231, fontFamily: 'ionicons'),
                          color: Color(0xFF3B5998),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '''\
Últimas actualizaciones
Avisos: ${intToDateStr(avisos ?? 9999999999)}
Menú: ${intToDateStr(menu ?? 9999999999)}
Semestre: ${intToDateStr(semestre ?? 9999999999)}
Aplicación: ${intToDateStr(lastUpdated)}

Creada por Gabriel Rodríguez
Colaborador/Administrador: Carter R. Dieguiño''',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            );
            break;
          //TODO: checar que sí haya menú
          case Opciones.compartirMenu:
            final now = today;
            final monday = now.add(Duration(days: -now.weekday + 1));
            showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Compartir menú'),
                    content: const Text(
                        '¿Quieres compartir el menú de esta semana o el de la siguiente?'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Esta semana'),
                        onPressed: () {
                          Share.share(
                            container!.state.menuAsString(
                              from: monday,
                              to: monday.add(const Duration(days: 7)),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: const Text('Próxima semana'),
                        onPressed: () {
                          Share.share(
                            container!.state.menuAsString(
                              from: monday.add(const Duration(days: 7)),
                              to: monday.add(const Duration(days: 14)),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
            break;
          case Opciones.feedback:
            final connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult == ConnectivityResult.none) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Para enviar comentarios, necesitas una conexión a internet.')));
            } else {
              final result = await Navigator.of(context).pushNamed('/feedback');
              if (result == true) {
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text('¡Gracias por tus comentarios! 🎉'),
                  duration: Duration(seconds: 10),
                ));
              }
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Opciones>>[
        const PopupMenuItem<Opciones>(
          value: Opciones.actualizar,
          child: Text('Actualizar menú'),
        ),
        const PopupMenuItem<Opciones>(
          value: Opciones.compartir,
          child: Text('Compartir aplicación'),
        ),
        const PopupMenuItem<Opciones>(
          value: Opciones.compartirMenu,
          child: Text('Compartir menú'),
        ),
        if (!kIsWeb)
          const PopupMenuItem<Opciones>(
            value: Opciones.feedback,
            child: Text('Enviar sugerencias'),
          ),
        const PopupMenuItem<Opciones>(
          value: Opciones.acerca,
          child: Text('Acerca de'),
        ),
      ],
    );
  }
}

enum Opciones { actualizar, compartir, acerca, compartirMenu, feedback }
