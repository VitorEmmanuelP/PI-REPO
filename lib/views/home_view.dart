import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pi/constants/routes.dart';
import 'package:pi/models/bus_data.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:pi/utils/styles.dart';
import 'package:pi/views/aluno_list_view.dart';
import 'package:pi/views/criar_qr_code_view.dart';
import 'package:pi/views/presenca_view.dart';
import 'package:pi/views/qr_code_scanner_view.dart';

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

  BusData? infoAlunoOninus;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null) {
      dados = args;
    }

    PageController pageController = PageController(initialPage: 1);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          bottomNavigationBar: dados != null && dados!.status == 'coordenador'
              ? navBar(pageController)
              : null,
          backgroundColor: scaffoldColor,
          appBar: appBar(),
          body: dados != null && dados!.status == 'coordenador'
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
              Navigator.of(context).pushNamed(onibusRoute, arguments: dados);
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
              Navigator.of(context).pushNamed(presencaRoute,
                  arguments: [dados, infoAlunoOninus]);
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
                Navigator.of(context).pushNamed(infoBusAluno, arguments: dados);
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

    if (dados!.status == 'aluno' || dados!.status == 'coordenador') {
      if (dados!.idOnibus != '' || dados!.idOnibus != null) {
        await getAlunos();
        await getOnibusAluno();
      } else {
        await getAlunos();
      }
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
            placa: data['placa'],
            numeroVagas: data['numeroVagas'],
            profilePic: data['profilePic']);

        listaOnibus.add(onibus);
      }
    }

    saveListModels('listaOnibus', listaOnibus);
  }

  Future<void> getOnibusAluno() async {
    final snapshotBus = await FirebaseFirestore.instance
        .collection("prefeituras/${dados.idPrefeitura}/onibus/")
        .where('id', isEqualTo: dados.idOnibus)
        .limit(1)
        .get();

    final data = snapshotBus.docs[0].data();

    if (data.isNotEmpty) {
      final onibus = BusData(
        motorista: data['motorista'],
        id: data['id'],
        destino: data['destino'],
        idPrefeitura: data['idPrefeitura'],
        modelo: data['modelo'],
        placa: data['placa'],
        numeroVagas: data['numeroVagas'],
        profilePic: data['profilePic'],
      );

      setState(() {
        infoAlunoOninus = onibus;
      });
    }
  }

  Future<void> getTodosAlunos() async {
    final idPrefeitura = dados!.id;

    final snapshot = await FirebaseFirestore.instance
        .collection("prefeituras/$idPrefeitura/users/")
        .get();

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
            qrCode: data['qrCode']);

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
            qrCode: data['qrCode']);

        listaAlunos.add(aluno);
      }
    }

    await saveListModels('listaAlunos', listaAlunos);
  }

  AppBar appBar() {
    return AppBar(
      leading: dados!.status != 'prefeitura'
          ? Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .pushNamed(profileRoute, arguments: dados);
                  },
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.black,
                  ),
                  iconSize: 36.0,
                );
              },
            )
          : null,
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
