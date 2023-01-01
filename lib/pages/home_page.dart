import 'package:flutter/material.dart';
import 'package:cripto_moedas/pages/moedas_page.dart';

import 'carteira_page.dart';
import 'configuracoes_page.dart';
//import 'favoritas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        // ignore: sort_child_properties_last
        children: const [
          // ignore: prefer_const_constructors
          MoedasPage(),
          //const FavoritasPage(),
          CarteiraPage(),
          ConfiguracoesPage(),
        ],
        onPageChanged: setPaginaAtual,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        type: BottomNavigationBarType.fixed,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todas'),
          //const BottomNavigationBarItem(
          //icon: Icon(Icons.favorite), label: 'Favoritas'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Carteira'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Conta'),
        ],
        onTap: (pagina) {
          pc.animateToPage(
            pagina,
            duration: const Duration(microseconds: 400),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
