import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_refresh_indicator.dart';
import '../widgets/fab.dart';
import '../widgets/tab_contents.dart';
import '../state_container.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
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
        container.showRefreshIndicatorAndUpdate();
      }
    });
  }

  /// https://stackoverflow.com/questions/50131598/how-to-handle-app-lifecycle-with-flutter-on-android-and-ios
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    final container = StateContainer.of(context);
    container.showRefreshIndicatorAndUpdate();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    return DefaultTabController(
      initialIndex: hour > 15
          ? Alimento.cena
          : hour > 9
              ? Alimento.comida
              : Alimento.desayuno,
      length: 3,
      child: Scaffold(
        appBar: buildAppBar(
          context: context,
          setState: setState,
        ),
        body: const CustomRefreshIndicator(
          isTopLevel: true,
          child: TabBarView(
            children: <Widget>[
              TabContents(alimento: Alimento.desayuno),
              TabContents(alimento: Alimento.comida),
              TabContents(alimento: Alimento.cena),
            ],
          ),
        ),
        floatingActionButton: const Fab(),
      ),
    );
  }
}
