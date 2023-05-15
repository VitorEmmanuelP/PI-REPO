import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/services/firebase_messaging.dart';
import 'package:pi/services/notificantion_service.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/views/add_aluno_onibus_view.dart';
import 'package:pi/views/agenda_view.dart';
import 'package:pi/views/home_view.dart';
import 'package:pi/views/info_bus_view.dart';
import 'package:pi/views/aluno_list_view.dart';
import 'package:pi/views/login_view.dart';
import 'package:pi/views/onibus_list_view.dart';
import 'package:pi/views/pagamento_view.dart';
import 'package:pi/views/presenca_view.dart';
import 'package:pi/views/profile_view.dart';
import 'package:pi/views/qr_code_scanner_view.dart';
import 'package:pi/views/register_aluno_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pi/views/registrar_bus.dart';

import 'package:pi/views/user_view.dart';

import 'models/prefeitura_data.dart';
import 'models/user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationServices.initializeNotification();

  await FirebaseMessagingService().initialize();
  print(
      "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa");
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
        // splashColor: Colors.transparent,
        // highlightColor: Colors.transparent,
        // hoverColor: Colors.transparent,
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
        infoBusRoute: (context) => const InfoBusView(),
        listaAlunoRoute: (context) => const ListaAlunoView(),
        userRoute: (context) => const UserView(),
        addAlunoOnibusRoute: (context) => const AddALunoONibusView(),
        pagamentoRoute: (context) => const Pix(),
        qrScanner: (context) => QRCodeScannerScreen(),
      },
      //home: HomeView()
      home: dados.runtimeType == UserData || dados.runtimeType == PrefeituraData
          ? const HomeView()
          : const LoginView(),
    );
  }
}
