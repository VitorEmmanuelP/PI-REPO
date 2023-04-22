import 'package:flutter/material.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/views/agenda_view.dart';
import 'package:pi/views/home_view.dart';
import 'package:pi/views/info_bus_view.dart';
import 'package:pi/views/list_view.dart';
import 'package:pi/views/login_view.dart';
import 'package:pi/views/onibus_view.dart';
import 'package:pi/views/presenca_view.dart';
import 'package:pi/views/profile_view.dart';
import 'package:pi/views/register_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pi/views/registrar_bus.dart';
import 'package:pi/views/teste.dart';
import 'package:pi/views/user_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences shared = await SharedPreferences.getInstance();

  final dados = shared.getString('dados');
  print(dados);
  runApp(MyApp(dados: dados));
}

class MyApp extends StatelessWidget {
  final String? dados;
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
        },
        home: HomeView()
        //home: dados == 'Falso' ? const LoginView() : const HomeView(),
        );
  }
}
