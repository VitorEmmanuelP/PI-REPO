import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/bus_data.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/views/aluno_list_view.dart';
import 'package:pi/views/criar_qr_code_view.dart';
import 'package:pi/views/presenca_view.dart';
import 'package:pi/views/qr_code_scanner_view.dart';
import 'package:pi/views/registrar_bus.dart';

import '../services/notificantion_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  dynamic dados;
  int _selectedIndex = 1;
  List<UserData> listaAlunos = [];
  List<BusData> listaOnibus = [];

  final List pages = [
    profileRoute,
    homeRoute,
    criarQrCodeRoute,
  ];
  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 1);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          bottomNavigationBar: dados != null && dados!.status == 'cordenador'
              ? navBar(pageController)
              : null,
          backgroundColor: Colors.white,
          appBar: appBar(),
          body: dados != null && dados!.status == 'cordenador'
              ? pagaView(pageController, context)
              : pageOne(context)),
    );
  }

  PageView pagaView(PageController pageController, BuildContext context) {
    return PageView(
      onPageChanged: (index) {
        FocusScope.of(context).unfocus();
        setState(() {
          _selectedIndex = index;
        });
      },
      physics: const BouncingScrollPhysics(),
      controller: pageController,
      children: [QRCodeScannerScreen(), pageOne(context), const Pix()],
    );
  }

  Padding navBar(PageController pageController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GNav(
        gap: 8,
        activeColor: Colors.white,
        iconSize: 24,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        duration: const Duration(milliseconds: 500),
        tabBackgroundColor: Colors.blueGrey,
        tabs: const [
          GButton(
            icon: Icons.qr_code,
            text: 'Escaner',
          ),
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.payment,
            text: 'Pagamentos',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
            pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          });
        },
      ),
    );
  }

  SingleChildScrollView pageOne(BuildContext context) {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: dados != null && dados!.status == 'prefeitura'
            ? prefeituraHomeView(context)
            : alunoHomeView(context));
  }

  Center prefeituraHomeView(BuildContext context) {
    return Center(
        child: Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logo.png",
          height: 250,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => const ListaAlunoView(),
              //     settings: RouteSettings(arguments: dados)));
              Navigator.of(context)
                  .pushNamed(onibusRoute, arguments: listaOnibus);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "Onibus",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ListaAlunoView(),
                settings: RouteSettings(arguments: dados),
              ));
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "Lista de Alunos",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              //sendFcmMessage();
              // await NotificationServices.showNotification(
              //   title: "ADAWD",
              //   body: "CAPERA",
              //   payload: {'navigate': 'true'},
              // );
            },
            child: const Text('ada'))
      ],
    ));
  }

  Center alunoHomeView(BuildContext context) {
    return Center(
        child: Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logo.png",
          height: 250,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PresencaView(),
                settings: RouteSettings(arguments: dados),
              ));
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(80),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            child: const Text(
              "PRESENÇA",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(infoBusRoute);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(80),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Text(
                "INFO. Ônibus",
                style: TextStyle(color: Colors.black),
              )),
        ),
        ElevatedButton(
            onPressed: () async {
              //sendFcmMessage();
              // await NotificationServices.showNotification(
              //   title: "ADAWD",
              //   body: "CAPERA",
              //   payload: {'navigate': 'true'},
              // );
            },
            child: const Text('ada'))
      ],
    ));
  }

  void loadData() async {
    final dadosString = await getUser();

    setState(() {
      dados = dadosString;
    });
    if (dados!.status == 'prefeitura') {
      await getTodosAlunos();

      await getOnibus();
    }

    if (dados!.status == 'aluno' || dados!.status == 'cordenador') {
      await getAlunos();
    }
  }

  Future<void> getOnibus() async {
    final snapshotBus = await FirebaseFirestore.instance
        .collection("prefeituras/${dados!.id}/onibus/")
        .get();

    for (var doc in snapshotBus.docs) {
      final data = doc.data();

      if (data.isNotEmpty) {
        final onibus = BusData(
            motorista: data['motorista'],
            id: data['id'],
            destino: data['destino'],
            idPrefeitura: data['idPrefeitura'],
            modelo: data['modelo'],
            placa: data['placa']);

        listaOnibus.add(onibus);
      }
    }

    saveListModels('listaOnibus', listaOnibus);
  }

  Future<void> getTodosAlunos() async {
    final idPrefeitura = dados!.id;

    final snapshot = await FirebaseFirestore.instance
        .collection("prefeituras/$idPrefeitura/users/")
        .get();
    print(snapshot.docs.length);
    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data.isNotEmpty) {
        final aluno = UserData(
          nome: data['nome'],
          cpf: data['cpf'],
          profilePic: data['profilePic'],
          data: data['data'],
          curso: data['cursoAluno'],
          faculdade: data['faculdade'],
          telefone: data['telefone'],
          senha: data['senha'],
          status: data['status'],
          id: data['id'],
          idPrefeitura: data['idPrefeitura'],
          idOnibus: data['idOnibus'],
          token: data['token'],
        );

        listaAlunos.add(aluno);
      }
    }

    await saveListModels('listaAlunos', listaAlunos);
  }

  Future<void> getAlunos() async {
    final idPrefeitura = dados!.idPrefeitura;

    final snapshot = await FirebaseFirestore.instance
        .collection("prefeituras/$idPrefeitura/users/")
        .where('idOnibus', isEqualTo: dados!.idOnibus)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      print(data);
      if (data.isNotEmpty) {
        final aluno = UserData(
            nome: data['nome'],
            cpf: data['cpf'],
            profilePic: data['profilePic'],
            data: data['data'],
            curso: data['cursoAluno'],
            faculdade: data['faculdade'],
            telefone: data['telefone'],
            senha: data['senha'],
            status: data['status'],
            id: data['id'],
            idPrefeitura: data['idPrefeitura'],
            idOnibus: data['idOnibus'],
            token: data['token']);

        listaAlunos.add(aluno);
      }
    }

    await saveListModels('listaAlunos', listaAlunos);
  }

  AppBar appBar() {
    return AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            onPressed: () async {
              Navigator.of(context).pushNamed(profileRoute, arguments: dados);
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
            ),
            iconSize: 36.0,
          );
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black,
            )),
        IconButton(
            onPressed: () async {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout_sharp,
              color: Colors.black,
            ))
      ],
    );
  }
}
