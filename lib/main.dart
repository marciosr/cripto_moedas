import 'package:cripto_moedas/configs/app_settings.dart';
import 'package:cripto_moedas/repositories/conta_repository.dart';
import 'package:cripto_moedas/repositories/favoritas_repository.dart';
import 'package:cripto_moedas/repositories/moeda_repository.dart';
import 'package:cripto_moedas/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'meu_aplicativo.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
//import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'configs/hive_config.dart';

// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';

// Firebase dart
// import 'package:firebase_dart/core.dart';
// import 'package:firebase_dart/implementation/pure_dart.dart';
//import 'firebase_options.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();

  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
  }

  databaseFactory = databaseFactoryFfi;

  await HiveConfig.start();

  runApp(
    MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (context) => AuthService(app)),
        ChangeNotifierProvider(create: (context) => MoedaRepository()),
        ChangeNotifierProvider(
            create: (context) => ContaRepository(
                  moedas: context.read<MoedaRepository>(),
                )),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        // ChangeNotifierProvider(
        //     create: (context) => FavoritasRepository(
        //           //auth: context.read<AuthService>(),
        //           moedas: context.read<MoedaRepository>(),
        //         )),
      ],
      child: const MeuAplicativo(),
    ),
  );
}
