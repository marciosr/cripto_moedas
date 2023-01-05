import 'dart:async';
import 'dart:convert';

import 'package:cripto_moedas/models/moeda.dart';
import 'package:flutter/material.dart';

import '../database/db.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;

// extends ChangeNotifier server para criar um provider para esta classe ser
// utilizada em vários pontos do aplicativo
class MoedaRepository extends ChangeNotifier {
  List<Moeda> _tabela = [];

  List<Moeda> get tabela => _tabela; // Método get
  late Timer intervalo;

  MoedaRepository() {
    // Método construtor
    _setupMoedasTable();
    _setupDadosTableMoeda();
    _readMoedasTable();
    _refreshPrecos();
  }
  _refreshPrecos() async {
    intervalo =
        Timer.periodic(const Duration(minutes: 5), (_) => checkPrecos());
  }

  checkPrecos() async {
    String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> moedas = json['data'];

      Database db = await DB.instance.database;
      Batch batch = db.batch();

      _tabela.forEach((atual) {
        moedas.forEach((nova) {
          if (atual.baseId == nova['base_id']) {
            final moeda = nova['prices'];
            final preco = nova['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            batch.update(
              'moedas',
              {
                'preco': moeda['latest'],
                'timestamp': timestamp.microsecondsSinceEpoch,
                'mudancaHora': preco['percent_change']['hour'].toString(),
                'mudancaDia': preco['percent_change']['day'].toString(),
                'mudancaSemana': preco['percent_change']['week'].toString(),
                'mudancaMes': preco['percent_change']['month'].toString(),
                'mudancaAno': preco['percent_change']['year'].toString(),
                'mudancaPeriodoTotal':
                    preco['percent_change']['all'].toString(),
              },
              where: 'baseId = ?',
              whereArgs: [atual.baseId],
            );
          }
        });
      });
      await batch.commit(noResult: true);
      await _readMoedasTable();
    }
  }

  // Ler os dados do banco de dados e retornar as moedas em uma lista.
  _readMoedasTable() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('moedas');

    _tabela = resultados.map((row) {
      return Moeda(
        baseId: row['baseId'],
        icone: row['icone'],
        sigla: row['sigla'],
        nome: row['nome'],
        preco: double.parse(row['preco']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        mudancaHora: double.parse(row['mudancaHora']),
        mudancaDia: double.parse(row['mudancaDia']),
        mudancaSemana: double.parse(row['mudancaSemana']),
        mudancaMes: double.parse(row['mudancaMes']),
        mudancaAno: double.parse(row['mudancaAno']),
        mudancaPeriodoTotal: double.parse(row['mudancaPeriodoTotal']),
      );
    }).toList();
    notifyListeners();
  }

  _moedasTableIsEmpty() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('moedas');
    // print('*** A TABELA ESTÁ VAZIA??????');
    // print(resultados.isEmpty);
    return resultados.isEmpty;
  }

  _setupDadosTableMoeda() async {
    if (await _moedasTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> moedas = json['data'];
        Database db = await DB.instance.database;
        Batch batch = db.batch();

        for (var moeda in moedas) {
          final preco = moeda['latest_price'];
          final timestamp = DateTime.parse(preco['timestamp']);

          batch.insert('moedas', {
            'baseId': moeda['id'],
            'sigla': moeda['symbol'],
            'nome': moeda['name'],
            'icone': moeda['image_url'],
            'preco': moeda['latest'],
            'timestamp': timestamp.microsecondsSinceEpoch,
            'mudancaHora': preco['percent_change']['hour'].toString(),
            'mudancaDia': preco['percent_change']['day'].toString(),
            'mudancaSemana': preco['percent_change']['week'].toString(),
            'mudancaMes': preco['percent_change']['month'].toString(),
            'mudancaAno': preco['percent_change']['year'].toString(),
            'mudancaPeriodoTotal': preco['percent_change']['all'].toString(),
          });
        }

        await batch.commit(noResult: true);
      }
    }
  }

  _setupMoedasTable() async {
    // Estrutura da tabela SQL baseada no model Moeda.
    const String table = '''
				CREATE TABLE IF NOT EXISTS moedas (
					baseId TEXT PRIMARY KEY,
					sigla TEXT,
					nome TEXT,
					icone TEXT,
					preco TEXT,
					timestamp INTEGER,
					mudancaHora TEXT,
					mudancaDia TEXT,
					mudancaSemana TEXT,
					mudancaMes TEXT,
					mudancaAno TEXT,
					mudancaPeriodoTotal TEXT
				);
			''';
    Database db = await DB.instance.database;
    await db.execute(table);
  }
}
