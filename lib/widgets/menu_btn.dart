import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:menu2018/constants.dart';
import 'package:menu2018/state_container.dart';
import 'package:menu2018/models.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:package_info/package_info.dart';

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
            container.showRefreshIndicatorAndUpdate();
            break;
          case Opciones.compartir:
            Share.share(
                'Descarga Menú Chapingo, la nueva app para ver el menú de la UACh: https://menu-chapingo.firebaseapp.com/dl.html');
            break;
          case Opciones.acerca:
            String intToDateStr(int n) {
              final String _string = n.toString();
              return '${_string.substring(6, 8)}/${meses[int.parse(_string.substring(4, 6)) - 1]}/${_string.substring(0, 4)} (${int.parse(_string.substring(8, 10))})';
            }
            final prefs = await SharedPreferences.getInstance();
            final packageInfo = await PackageInfo.fromPlatform();
            final lastUpdated = int.parse(packageInfo.buildNumber);
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                          title: const Text('Google Play'),
                          subtitle: const Text(
                              'Si te gusta la app, danos 5 estrellas 😉, o comparte tu opinión'),
                          leading: const Icon(Icons.shop, color: Colors.green),
                          onTap: () async {
                            try {
                              url_launcher.launch(
                                  'market://details?id=com.gabo.menu2018');
                            } catch (e) {
                              url_launcher.launch(
                                  'https://play.app.goo.gl/?link=https://play.google.com/store/apps/details?id=com.gabo.menu2018');
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
                              url_launcher.launch(iosUrl);
                            } catch (e) {
                              url_launcher.launch(url);
                            }
                          } else if (await url_launcher.canLaunch(url)) {
                            url_launcher.launch(url);
                          } else {
                            Scaffold.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Error al abrir página de Facebook.'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        leading: const Icon(
                          IconData(0xf231, fontFamily: 'ionicons'),
                          color: Color(0xFF3B5998),
                        ),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(bottom: 16.0),
                ),
                Text(
                  '''\
Últimas actualizaciones
Avisos: ${intToDateStr(avisos)}
Menú: ${intToDateStr(menu)}
Semestre: ${intToDateStr(semestre)}
Aplicación: ${intToDateStr(lastUpdated)}

Creada por Gabriel Rodríguez''',
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
                            container.state.menuAsString(
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
                            container.state.menuAsString(
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
              Navigator.of(context).pushNamed('/feedback').then<bool>((value) {
                if (value ?? false) {
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text('¡Gracias por tus comentarios! 🎉'),
                    duration: Duration(seconds: 10),
                  ));
                }
              });
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
                value: Opciones.compartirMenu, child: Text('Compartir menú')),
            const PopupMenuItem<Opciones>(
                value: Opciones.feedback, child: Text('Enviar sugerencias')),
            const PopupMenuItem<Opciones>(
              value: Opciones.acerca,
              child: Text('Acerca de'),
            ),
          ],
    );
  }
}

enum Opciones { actualizar, compartir, acerca, compartirMenu, feedback }
