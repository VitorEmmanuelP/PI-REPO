import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/services/firebase_messaging.dart';
import 'package:pi/services/notificantion_service.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/views/add_aluno_onibus_view.dart';
import 'package:pi/views/agenda_view.dart';
import 'package:pi/views/criar_qr_code_view.dart';
import 'package:pi/views/esqueci_senha.dart';
import 'package:pi/views/home_view.dart';
import 'package:pi/views/aluno_list_view.dart';
import 'package:pi/views/lista_pagamentos.dart';
import 'package:pi/views/lista_presenca_view.dart';
import 'package:pi/views/login_view.dart';
import 'package:pi/views/onibus_list_view.dart';
import 'package:pi/views/onibus_view.dart';
import 'package:pi/views/pagamento_preview_view.dart';
import 'package:pi/views/pagamento_view.dart';
import 'package:pi/views/presenca_view.dart';
import 'package:pi/views/presensa_unica_view.dart';
import 'package:pi/views/profile_view.dart';
import 'package:pi/views/qr_code_scanner_view.dart';
import 'package:pi/views/register_aluno_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pi/views/registrar_bus.dart';

import 'package:pi/views/user_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationServices.initializeNotification();

  await FirebaseMessagingService().initialize();

  final dynamic dados = await getUser();

  runApp(MyApp(
    dados: dados,
  ));
}

class MyApp extends StatelessWidget {
  final dynamic dados;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({
    super.key,
    this.dados,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          splashColor: Colors.white,
          brightness: Brightness.light,
          primaryColor: Colors.green,
        ),
        navigatorKey: navigatorKey,
        routes: {
          profileRoute: (context) => const ProfileView(),
          homeRoute: (context) => const HomeView(),
          loginRoute: (context) => const LoginView(),
          registerAlunoRoute: (context) => const RegistrarAlunoView(),
          registerBusRoute: (context) => const RegistrarOnibusView(),
          onibusRoute: (context) => const OnibusView(),
          agendaRoute: (context) => const AgendaView(),
          presencaRoute: (context) => const PresencaView(),
          presencaUnicaRoute: (context) => const PresencaUnicaView(),
          presencaTodosRoute: (context) => const ListaPresensaView(),
          listaBusRoute: (context) => const OnibusView(),
          infoBusRoute: (context) => const InfoBusView(),
          listaAlunoRoute: (context) => const ListaAlunoView(),
          userRoute: (context) => const UserView(),
          addAlunoOnibusRoute: (context) => const AddALunoONibusView(),
          pagamentoPreviwRoute: (context) => const PagamentoPreviewView(),
          pagamentoRoute: (context) => const PagamentoView(),
          criarQrCodeRoute: (context) => const Pix(),
          listaPagamentoPixRoute: (context) => const ListaPagamentosView(),
          qrScanner: (context) => QRCodeScannerScreen(),
          esqueceSenha: (context) => const EsqueceSenhaView(),
        },
        home: const LoginView()
        // home: dados.runtimeType == UserData || dados.runtimeType == PrefeituraData
        //     ? const HomeView()
        //     : const LoginView(),
        );
  }
}
