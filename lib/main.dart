import 'dart:io';

import 'package:evoteapp/components/styles.dart';
import 'package:evoteapp/screens/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:logging/logging.dart';

import 'auth/auth_manager.dart';

AuthManager authManager = AuthManager();

void main() {
  HttpOverrides.global = MyHttpOverrides();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF9FC2CC)),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF9FC2CC)),
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
