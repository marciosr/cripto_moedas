import 'package:cripto_moedas/configs/app_settings.dart';
import 'package:cripto_moedas/repositories/conta_repository.dart';
import 'package:cripto_moedas/repositories/favoritas_repository.dart';
import 'package:cripto_moedas/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'configs/hive_config.dart';
import 'meu_aplicativo.dart';
import 'package:provider/provider.dart';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

// Firebase
//import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Firebase dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_dart/auth.dart';
import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/database.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
import 'package:firebase_dart/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  FirebaseDart.setup();

  const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKSO-0cdee0Pvp-GUMYhka9aRHjEgHmJY',
    appId: '1:142152035556:android:d6bcb3e3e8aa476a7e10f1',
    messagingSenderId: '142152035556',
    projectId: 'fire-base-teste-edc42',
    storageBucket: 'fire-base-teste-edc42.appspot.com',
  );

  var app = await Firebase.initializeApp(options: android);

  //var auth = FirebaseAuth.instanceFor(app: app);

  //var user = auth.currentUser;

  //if (Platform.isLinux || Platform.isWindows) {
  //  sqfliteFfiInit();
  //}

  databaseFactory = databaseFactoryFfi;

  await HiveConfig.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService(app)),
        ChangeNotifierProvider(create: (context) => ContaRepository()),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(create: (context) => FavoritasRepository()),
      ],
      child: const MeuAplicativo(),
    ),
  );
}
