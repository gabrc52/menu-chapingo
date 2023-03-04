import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:menu2018/screens/feedback.dart';
import 'package:menu2018/widgets/fab.dart';
import 'package:universal_platform/universal_platform.dart';
import '../state_container.dart';
import '../models/app_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
          label: 'Ajustes',
          onTap: (option) {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ],
      icon: Icon(context.platformIcons.ellipsis),
    );
  }
}

enum Opciones { actualizar, compartir, acerca, compartirMenu, feedback }
