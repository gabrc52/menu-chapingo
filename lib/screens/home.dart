import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menu2018/constants.dart';
import 'package:menu2018/widgets/appbar.dart';
import 'package:menu2018/widgets/custom_refresh_indicator.dart';
import 'package:menu2018/widgets/fab.dart';
import 'package:menu2018/widgets/tab_contents.dart';
import 'package:menu2018/state_container.dart';
import 'package:connectivity/connectivity.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<ConnectivityResult> subscription;
  
  // Si hay algún cambio en la conexión, volver a intentar la actualización
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final container = StateContainer.of(context);
    subscription ??= Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        container.showRefreshIndicatorAndUpdate();
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    return DefaultTabController(
      initialIndex: hour > 15
          ? Alimento.cena
          : hour > 9 ? Alimento.comida : Alimento.desayuno,
      length: 3,
      child: Scaffold(
        appBar: buildAppBar(
          context: context,
          setState: setState,
        ),
        body: const CustomRefreshIndicator(
          child: TabBarView(
            children: <Widget>[
              TabContents(Alimento.desayuno),
              TabContents(Alimento.comida),
              TabContents(Alimento.cena),
            ],
          ),
          isTopLevel: true,
        ),
        floatingActionButton: Fab(),
      ),
    );
  }
}
