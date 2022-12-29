import 'package:cripto_moedas/configs/app_settings.dart';
import 'package:cripto_moedas/repositories/conta_repository.dart';
import 'package:cripto_moedas/repositories/favoritas_repository.dart';
import 'package:cripto_moedas/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'configs/hive_config.dart';
import 'meu_aplicativo.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

//import 'package:sqflite_common/sqlite_api.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
//import 'dart:io';

// Firebase
//import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Firebase dart
//import 'package:firebase_dart/auth.dart';
import 'package:firebase_dart/core.dart';
//import 'package:firebase_dart/database.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
//import 'package:firebase_dart/storage.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  FirebaseDart.setup();

  const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXY8a-M6KwLBVmwGOZFBb3BtTz63_fGXw',
    appId: '1:831986672203:android:c69537bb39ee913440e3ce',
    messagingSenderId: '831986672203',
    projectId: 'cripto-firebase-372921',
    storageBucket: 'cripto-firebase-372921.appspot.com',
  );

  const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCXY8a-M6KwLBVmwGOZFBb3BtTz63_fGXw',
    appId: '1:831986672203:android:c69537bb39ee913440e3ce',
    messagingSenderId: '831986672203',
    projectId: 'cripto-firebase-372921',
    storageBucket: 'cripto-firebase-372921.appspot.com',
  );

  var app = await Firebase.initializeApp(options: android);
  // var app = await Firebase.initializeApp(
  //  options: DefaultFirebaseOptions.currentPlatform,
  //);

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
        ChangeNotifierProvider(
            create: (context) => FavoritasRepository(
                  auth: context.read<AuthService>(),
                )),
      ],
      child: const MeuAplicativo(),
    ),
  );
}
