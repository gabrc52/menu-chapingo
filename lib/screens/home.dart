import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../constants.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_refresh_indicator.dart';
import '../widgets/fab.dart';
import '../widgets/tab_contents.dart';
import '../state_container.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<ConnectivityResult>? subscription;

  // Si hay algún cambio en la conexión, volver a intentar la actualización
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final container = StateContainer.of(context);
    subscription ??= Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        container?.showRefreshIndicatorAndUpdate();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    return CupertinoTheme(
      data: CupertinoThemeData(brightness: Theme.of(context).brightness),
      child: Scaffold(
        body: PlatformTabScaffold(
          items: const [
            BottomNavigationBarItem(
              label: 'Desayuno',
              icon: Icon(Icons.egg_alt),
            ),
            BottomNavigationBarItem(
              label: 'Comida',
              icon: Icon(Icons.dinner_dining),
            ),
            BottomNavigationBarItem(
              label: 'Cena',
              icon: Icon(Icons.coffee),
            ),
          ],
          tabController: PlatformTabController(
            initialIndex: hour > 15
                ? Alimento.cena
                : hour > 9
                    ? Alimento.comida
                    : Alimento.desayuno,
          ),
          appBarBuilder: (context, index) => buildAppBar(
            context: context,
            setState: setState,
          ),
          bodyBuilder: (context, index) => const <Widget>[
            TabContents(Alimento.desayuno),
            TabContents(Alimento.comida),
            TabContents(Alimento.cena),
          ][index],
          material: (context, target) => MaterialTabScaffoldData(
            floatingActionButton: Fab(),
          ),
          cupertino: (context, target) => CupertinoTabScaffoldData(
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
