import 'dart:collection';
import 'package:cripto_moedas/database/db_firestore.dart';
import 'package:cripto_moedas/repositories/moeda_repository.dart';
import 'package:cripto_moedas/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../adapters/moedas_hive_adapter.dart';
import '../models/moeda.dart';
//import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritasRepository extends ChangeNotifier {
  List<Moeda> _lista = [];

  //late LazyBox box;
  late FirebaseFirestore db;
  late AuthService auth;

  FavoritasRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
//    await _openBox();
    await _startFirestore();
    await _readFavoritas();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

//  _openBox() async {
//    Hive.registerAdapter(MoedaHiveAdapter());
//    box = await Hive.openLazyBox<Moeda>('moedas_favoritas');
//  }

  // _readFavoritas() async {
  //   box.keys.forEach((moeda) async {
  //     Moeda m = await box.get(moeda);
  //     _lista.add(m);
  //     notifyListeners();
  //   });
  // }

  _readFavoritas() async {
    if (auth.usuario != null && _lista.isEmpty) {
      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      snapshot.docs.forEach((doc) {
        Moeda moeda = MoedaRepository.tabela
            .firstWhere((moeda) => moeda.sigla == doc.get('sigla'));
        _lista.add(moeda);
        notifyListeners();
      });
    }
  }

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  //saveAll(List<Moeda> moedas) {
  //  moedas.forEach((moeda) {
  //    if (!_lista.contains(moeda)) _lista.add(moeda);
  //  });

  //  notifyListeners();
  //}

  saveAll(List<Moeda> moedas) {
    moedas.forEach((moeda) async {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favoritas')
            .doc(moeda.sigla)
            .set({
          'moeda': moeda.nome,
          'sigla': moeda.sigla,
          'preco': moeda.preco,
        });
      }
    });

    notifyListeners();
  }

  remove(Moeda moeda) async {
    await db
        .collection('usuario/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .delete();

    _lista.remove(moeda);

    notifyListeners();
  }
}
