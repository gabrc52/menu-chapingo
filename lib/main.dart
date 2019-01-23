//import 'oldmain.dart' as oldmain show main;
import 'package:flutter/material.dart';
import 'app.dart';
import 'models.dart';
import 'state_container.dart';

Future<void> main() async {
  //oldmain.main();
  final appState = AppState();
  await appState.loadFromPrefs();
  runApp(StateContainer(
    child: MenuApp(),
    state: appState,
  ));
}
