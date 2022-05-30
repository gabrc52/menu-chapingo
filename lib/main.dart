import 'dart:async';
import 'package:flutter/material.dart';
import 'app.dart';
import 'models.dart';
import 'state_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final appState = AppState();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await appState.loadFromPrefs();
  runApp(StateContainer(
    state: appState,
    child: MenuApp(),
  ));
}
