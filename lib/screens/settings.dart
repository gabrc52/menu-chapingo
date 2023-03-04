import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:menu2018/models/last_updates.dart';
import 'package:menu2018/models/settings.dart';
import 'package:menu2018/state_container.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Consumer<Settings>(
          builder: (context, settings, child) => SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Apariencia'),
                tiles: [
                  SettingsTile(
                    title: const Text('Tema'),
                    leading: const Icon(Icons.palette),
                    value: Text(settings.theme.string()),
                    onPressed: (option) {
                      final settings =
                          Provider.of<Settings>(context, listen: false);
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
                ],
              ),
              SettingsSection(
                title: const Text('Acerca de'),
                tiles: [
                  SettingsTile(
                    title: Text(
                        UniversalPlatform.isIOS ? 'App Store' : 'Google Play'),
                    description: const Text(
                        'Si te gusta la app, danos 5 estrellas 😉, o comparte tu opinión'),
                    leading: Icon(
                      UniversalPlatform.isIOS
                          ? const IconData(0xf227, fontFamily: 'ionicons')
                          : Icons.shop,
                      color: UniversalPlatform.isIOS ? null : Colors.green,
                    ),
                    onPressed: (context) async {
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
                  SettingsTile(
                    title: const Text('Página de Facebook'),
                    description: const Text('No olvides dejar tu like 😉'),
                    onPressed: (context) async {
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
                  CustomSettingsTile(
                    child: FutureBuilder<LastUpdates>(
                      future: LastUpdate.getAll(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final LastUpdates updates = snapshot.data!;
                          return SettingsTile(
                            leading: const Icon(Icons.update),
                            title: const Text('Últimas actualizaciones'),
                            description: Text(
                              'Menú: ${updates.menu}\nAvisos: ${updates.avisos}\nSemestre: ${updates.fechas}\nAplicación: ${updates.app}',
                            ),
                            onPressed: (context) {
                              final container = StateContainer.of(context);
                              container.showRefreshIndicatorAndUpdate();
                            },
                          );
                        } else {
                          return const SizedBox(); // nothing
                        }
                      },
                    ),
                  ),
                  SettingsTile(
                    title: const Text('Agradecimientos'),
                    leading: const Icon(Icons.volunteer_activism),
                    description: const Text(
                        'App: Gabriel Rodríguez\nAdmin: Diego Ramos\nAdmin: Flor\nUACh y Comisión de Alimentación por el servicio'),
                  ),
                  SettingsTile(
                    title: const Text('Ver licencias'),
                    leading: const Icon(Icons.copyright),
                    onPressed: (context) => showLicensePage(
                      context: context,
                      applicationName: 'Menú Chapingo',
                      applicationVersion: 'La mejor app para ver el menú',
                      applicationIcon: const Icon(Icons.restaurant_menu),
                    ),
                  ),
                ],
              ),
            ],

            /// Respetar el tema
            lightTheme: const SettingsThemeData(
              settingsListBackground: Colors.transparent,
            ),
            darkTheme: const SettingsThemeData(
              settingsListBackground: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Se ve muy raro/feo ponerlo en 4 elementos distintos
/// así que no voy a usar esta clase
// class LastUpdateTile extends AbstractSettingsTile {
//   const LastUpdateTile({
//     super.key,
//     required this.category,
//     required this.lastUpdateFuture,
//   });

//   final String category;
//   final Future<String> lastUpdateFuture;

//   @override
//   Widget build(BuildContext context) {
//     return CustomSettingsTile(
//       child: FutureBuilder(
//         future: lastUpdateFuture,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return SettingsTile(
//               leading: const Icon(Icons.update),
//               title: Text(category),
//               description: Text('Última actualización: ${snapshot.data}'),
//               onPressed: (context) {
//                 final container = StateContainer.of(context);
//                 container.showRefreshIndicatorAndUpdate();
//               },
//             );
//           } else {
//             return const SizedBox(); // nothing
//           }
//         },
//       ),
//     );
//   }
// }
