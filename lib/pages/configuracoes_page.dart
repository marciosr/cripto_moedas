import 'dart:io';
//import 'dart:ui';

import 'package:cripto_moedas/configs/app_settings.dart';
import 'package:cripto_moedas/repositories/conta_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'documentos_page.dart';
//import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({Key? key}) : super(key: key);

  @override
  _ConfiguracoesPageState createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  XFile? comprovante;

  @override
  Widget build(BuildContext context) {
    final conta = context.watch<ContaRepository>();
    final loc = context.read<AppSettings>().locale;
    NumberFormat real =
        NumberFormat.currency(locale: loc['locale'], name: loc['name']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              title: const Text('Saldo'),
              subtitle: Text(
                real.format(conta.saldo),
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.indigo,
                ),
              ),
              trailing: IconButton(
                  onPressed: updateSaldo, icon: const Icon(Icons.edit)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Escanear documentos'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentosPage(),
                  fullscreenDialog: true,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Enviar comprovante (foto)'),
              onTap: selecionarComprovante,
              trailing: comprovante != null
                  ? Image.file(File(comprovante!.path))
                  : null,
            ),
            const Divider(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: OutlinedButton(
                    onPressed: () => context.read<AuthService>().logout(),
                    style: OutlinedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Sair do App',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  selecionarComprovante() async {
    final ImagePicker picker = ImagePicker();
    try {
      XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) setState(() => comprovante = file);
    } catch (e) {
      print(e);
    }
  }

  updateSaldo() async {
    final form = GlobalKey<FormState>();
    final valor = TextEditingController();
    final conta = context.read<ContaRepository>();
    valor.text = conta.saldo.toString();
    //print(conta.saldo.toString());

    AlertDialog dialog = AlertDialog(
      title: const Text('Atualizar o saldo'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: valor,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          validator: (value) {
            if (value!.isEmpty) return 'Informar o valor do saldo';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        TextButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              conta.setSaldo(double.parse(valor.text));
              Navigator.pop(context);
            }
          },
          child: const Text('SALVAR'),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
  }
}
