import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:menu2018/models/settings.dart';
import 'package:menu2018/screens/feedback.dart';
import 'package:menu2018/widgets/fab.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';
import '../models/constants.dart';
import '../state_container.dart';
import '../models/app_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/settings.dart';

class MenuBtn extends StatelessWidget {
  const MenuBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    final box = context.findRenderObject() as RenderBox?;
    late final Rect? sharePositionOrigin;
    if (box != null) {
      sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
    }
    return PlatformPopupMenu(
      options: <PopupMenuOption>[
        PopupMenuOption(
          label: 'Cambiar fecha (día ${container.state.diaDelCiclo})',
          onTap: (option) {
            Fab.changeDate(context);
          },
        ),
        PopupMenuOption(
          label: 'Actualizar menú',
          onTap: (option) {
            container.showRefreshIndicatorAndUpdate();
          },
        ),
        PopupMenuOption(
          label: 'Compartir aplicación',
          onTap: (option) {
            Share.share(
              'Descarga Menú Chapingo, la nueva app para ver el menú de la UACh: https://menu-chapingo.web.app/dl.html',
              sharePositionOrigin: sharePositionOrigin,
            );
          },
        ),
        PopupMenuOption(
          label: 'Compartir menú',
          onTap: (option) {
            final now = today;
            final monday = now.add(Duration(days: -now.weekday + 1));
            showPlatformDialog(
                context: context,
                builder: (BuildContext context) {
                  return PlatformAlertDialog(
                    title: const Text('Compartir menú'),
                    content: const Text(
                        '¿Quieres compartir el menú de esta semana o el de la siguiente?'),
                    actions: <Widget>[
                      PlatformDialogAction(
                        child: const Text('Esta semana'),
                        onPressed: () {
                          Share.share(
                            container.state.menuAsString(
                              from: monday,
                              to: monday.add(const Duration(days: 7)),
                            ),
                            sharePositionOrigin: sharePositionOrigin,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      PlatformDialogAction(
                        child: const Text('Próxima semana'),
                        onPressed: () {
                          Share.share(
                            container.state.menuAsString(
                              from: monday.add(const Duration(days: 7)),
                              to: monday.add(const Duration(days: 14)),
                            ),
                            sharePositionOrigin: sharePositionOrigin,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
        ),
        PopupMenuOption(
          label: 'Enviar sugerencias',
          onTap: (option) async {
            showPlatformDialog(
              context: context,
              builder: (newContext) {
                return PlatformAlertDialog(
                  title: const Text('Enviar comentarios'),
                  content: const Text(
                      '¿Quieres enviar comentarios sobre la aplicación o sobre el servicio de alimentación?'),
                  actions: [
                    PlatformDialogAction(
                      child: PlatformText('Aplicación'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final connectivityResult =
                            await Connectivity().checkConnectivity();
                        if (connectivityResult == ConnectivityResult.none) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Para enviar comentarios, necesitas una conexión a internet.'),
                            ),
                          );
                        } else {
                          navigator.pop();
                          final result = await navigator.push(platformPageRoute(
                              context: context,
                              builder: (context) => const FeedbackPage()));
                          if (result == true) {
                            messenger.clearSnackBars();
                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('¡Gracias por tus comentarios! 🎉'),
                                duration: Duration(seconds: 10),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    PlatformDialogAction(
                      child: PlatformText('Servicio'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        const messengerUrlScheme =
                            'fb-messenger://user-thread/1557039931179093';
                        const messengerUrl = 'https://m.me/1557039931179093';

                        if (await canLaunchUrl(Uri.parse(messengerUrlScheme))) {
                          launchUrl(Uri.parse(messengerUrlScheme));
                        } else {
                          launchUrl(
                            Uri.parse(messengerUrl),
                            mode: UniversalPlatform.isAndroid
                                ? LaunchMode.externalApplication
                                : LaunchMode.platformDefault,
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        PopupMenuOption(
          label: 'Cambiar tema',
          onTap: (option) {
            final settings = Provider.of<Settings>(context, listen: false);
            showPlatformDialog(
              context: context,
              builder: (context) => PlatformAlertDialog(
                title: const Text('Tema'),
                content: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var value in SelectedTheme.values)
                        RadioListTile<SelectedTheme>(
                          title: Text(value.string()),
                          value: value,
                          groupValue: settings.theme,
                          onChanged: (value) {
                            if (value != null) {
                              settings.theme = value;
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        PopupMenuOption(
          label: 'Acerca de',
          onTap: (option) async {
            final theme = Theme.of(context);

            String intToDateStr(int n) {
              final String string = n.toString();
              return '${string.substring(6, 8)}/${meses[int.parse(string.substring(4, 6)) - 1]}/${string.substring(0, 4)} (${int.parse(string.substring(8, 10))})';
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
                      ListTile(
                        title: Text(UniversalPlatform.isIOS
                            ? 'App Store'
                            : 'Google Play'),
                        subtitle: const Text(
                            'Si te gusta la app, danos 5 estrellas 😉, o comparte tu opinión'),
                        leading: Icon(
                          UniversalPlatform.isIOS
                              ? const IconData(0xf227, fontFamily: 'ionicons')
                              : Icons.shop,
                          color: UniversalPlatform.isIOS ? null : Colors.green,
                        ),
                        onTap: () async {
                          if (UniversalPlatform.isIOS) {
                            const String appStoreUrl =
                                'https://apps.apple.com/mx/app/men%C3%BA-chapingo/id1627445872';
                            launchUrl(Uri.parse(appStoreUrl),
                                mode: LaunchMode.externalApplication);
                          } else {
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
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Página de Facebook'),
                        subtitle: const Text('No olvides dejar tu like 😉'),
                        onTap: () async {
                          //analytics.logEvent(name: 'fb');
                          const String iosUrl = 'fb://profile/214398592630533';
                          const String androidUrl = 'fb://page/214398592630533';
                          const String url =
                              'https://www.facebook.com/menuchapingo/';
                          if (UniversalPlatform.isIOS ||
                              UniversalPlatform.isMacOS) {
                            if (await canLaunchUrl(Uri.parse(iosUrl))) {
                              launchUrl(Uri.parse(iosUrl));
                            } else {
                              launchUrl(Uri.parse(url));
                            }
                          } else {
                            if (await canLaunchUrl(Uri.parse(androidUrl))) {
                              launchUrl(
                                Uri.parse(androidUrl),
                                mode: LaunchMode.externalNonBrowserApplication,
                              );
                            } else {
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            }
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
                  style: theme.textTheme.caption,
                ),
              ],
            );
          },
        ),
      ],
      icon: Icon(context.platformIcons.ellipsis),
    );
  }
}

enum Opciones { actualizar, compartir, acerca, compartirMenu, feedback }
