import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:pi/classes/profile_picture.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureWidget extends StatefulWidget {
  const ProfilePictureWidget({Key? key}) : super(key: key);

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  String? imagepath;
  ProfileImage? user;
  Map? dados;
  String imageUrl = '';
  List<String> nome = [];

  final picker = ImagePicker();

  @override
  void initState() {
    loadDados();
    initUser();
    loadImage();
    super.initState();
  }

  void initUser() async {
    user = ProfileImage(imgFromGallery, imgFromCamera);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prefeituras/${dados?['idPrefeitura']}/users')
            .where('id', isEqualTo: dados?['id'])
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 70,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return CircleAvatar(
              radius: 70,
              child: Center(
                child: Text(
                  "${nome.isNotEmpty ? nome[0][0] : ''}${nome.isNotEmpty && nome.length > 1 ? nome[1][0] : ''}",
                  style: const TextStyle(color: Colors.white, fontSize: 35),
                ),
              ),
            );
          } else {
            final a = snapshot.data?.docs.first.data() as Map?;

            if (a?['profilePic'] == '') {
              return GestureDetector(
                onTap: () => user?.showImagePicker(context),
                child: CircleAvatar(
                  radius: 70,
                  child: Center(
                    child: Text(
                      "${nome.isNotEmpty ? nome[0][0] : ''}${nome.isNotEmpty && nome.length > 1 ? nome[1][0] : ''}",
                      style: const TextStyle(color: Colors.white, fontSize: 35),
                    ),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () => user?.showImagePicker(context),
                child: ClipOval(
                  child: Image.network(
                    a?['profilePic'] ??
                        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width / 2,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          }
        });
  }

  void imgFromGallery() async {
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (file == null) return;

    await uploadFile(File(file.path));

    loadDados();
    // setState(() => arquivo = File(file.path));
    // saveImage(arquivo?.path);
  }

  void imgFromCamera() async {
    final file =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (file == null) return;

    await uploadFile(File(file.path));
    loadDados();
    // setState(() => arquivo = File(file.path));
    // saveImage(arquivo?.path);
  }

  void saveImage(arquivo) async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    saveimage.setString("imagepath", arquivo);
    setState(() {
      imagepath = saveimage.getString("imagepath");
    });
  }

  void loadImage() async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    setState(() {
      imagepath = saveimage.getString("imagepath");
    });
  }

  Future<Map?> loadDados() async {
    final userdata = await getInfoUser();

    setState(() {
      dados = userdata;
      nome = dados?['nome'].split(' ');

      imageUrl = dados!['profilePic'];
    });

    return dados;
  }

  Future<void> uploadFile(File file) async {
    // final firestore = FirebaseFirestore.instance;
    // final userDoc =
    //     await firestore.collection('users').doc('${dados!['id']}').get();

    // if (!userDoc.exists) {
    //   print('Usuário não existe no Firestore Database. Acesso negado.');
    //   return;
    // }

    String filename = DateTime.now().millisecondsSinceEpoch.toString();

    final storageRef = FirebaseStorage.instance.ref().child('image/$filename');

    try {
      final uploadTask = storageRef.putFile(file);
      await uploadTask;

      // Obter a URL de download do arquivo
      final downloadURL = await storageRef.getDownloadURL();

      final usera = FirebaseFirestore.instance
          .collection("prefeituras/${dados!['idPrefeitura']}/users/")
          .doc("${dados!['id']}");

      usera.update({'profilePic': downloadURL});

      dados!['profilePic'] = downloadURL;

      setVaribleShared('dados', dados);

      //print('Arquivo enviado com sucesso: $downloadURL');
    } catch (error) {
      //print('Erro ao enviar arquivo: $error');
    }
  }
}
