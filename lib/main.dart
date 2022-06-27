import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menu2018/models/settings.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'models/app_state.dart';
import 'state_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  final appState = AppState();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await appState.loadFromPrefs();

  /// Ask for notification permission and set up Firebase messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // ignore: unused_local_variable
  NotificationSettings settings = await messaging.requestPermission();

  runApp(ChangeNotifierProvider<Settings>(
    create: (context) => Settings(),
    builder: (context, child) => StateContainer(
      state: appState,
      child: const MenuApp(),
    ),
  ));
}
