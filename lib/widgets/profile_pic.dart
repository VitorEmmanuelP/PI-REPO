import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:pi/widgets/profile_picture.dart';
import 'package:pi/models/user_data.dart';
import 'package:pi/utils/dados_users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureWidget extends StatefulWidget {
  final Map? info;
  const ProfilePictureWidget({Key? key, this.info}) : super(key: key);

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  Map? infor = {};
  String? imagepath;
  ProfileImage? user;
  dynamic dados;
  String? imageUrl = '';
  List<String> nome = [];

  final picker = ImagePicker();

  @override
  void initState() {
    infor = widget.info ?? {};

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
    return ImagemUsuario(dados: dados, user: user, nome: nome);
  }

  void imgFromGallery() async {
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (file == null) return;

    await uploadFile(File(file.path));

    loadDados();
  }

  void imgFromCamera() async {
    final file =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (file == null) return;

    await uploadFile(File(file.path));
    loadDados();
  }

  void loadImage() async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    setState(() {
      imagepath = saveimage.getString("imagepath");
    });
  }

  Future<dynamic> loadDados() async {
    if (infor!.isEmpty) {
      final userdata = await getUser();
      setState(() {
        dados = userdata;

        nome = dados!.nome.split(' ');

        imageUrl = dados!.profilePic;
      });

      return dados;
    } else {
      setState(() {
        dados = infor;

        nome = dados['motorista'].trim().split(' ');

        imageUrl = dados['profilePic'];
      });
    }
  }

  Future<void> uploadFile(File file) async {
    if (infor!.isEmpty) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${dados!.id}/${dados!.id}');
      try {
        final uploadTask = storageRef.putFile(file);
        await uploadTask;

        final downloadURL = await storageRef.getDownloadURL();

        final usera = FirebaseFirestore.instance
            .collection("prefeituras/${dados!.idPrefeitura}/users/")
            .doc(dados!.id);

        usera.update({'profilePic': downloadURL});

        dados!.profilePic = downloadURL;

        saveUserOrPrefeitura('dados', dados);

        //print('Arquivo enviado com sucesso: $downloadURL');
      } catch (error) {
        //print('Erro ao enviar arquivo: $error');
      }
    } else {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${dados['id']}/${dados['id']}');
      try {
        final uploadTask = storageRef.putFile(file);
        await uploadTask;

        final downloadURL = await storageRef.getDownloadURL();

        final usera = FirebaseFirestore.instance
            .collection("prefeituras/${dados['idPrefeitura']}/onibus/")
            .doc(dados['id']);

        usera.update({'profilePic': downloadURL});

        dados!.profilePic = downloadURL;

        saveUserOrPrefeitura('dados', dados);

        //print('Arquivo enviado com sucesso: $downloadURL');
      } catch (error) {
        //print('Erro ao enviar arquivo: $error');
      }
    }
  }
}

// ignore: must_be_immutable
class ImagemUsuario extends StatelessWidget {
  dynamic dados;
  ProfileImage? user;
  List<String> nome = [];

  ImagemUsuario(
      {super.key, required this.dados, required this.user, required this.nome});

  @override
  Widget build(BuildContext context) {
    return dados != null && dados.runtimeType == UserData
        ? StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('prefeituras/${dados!.idPrefeitura}/users')
                .where('id', isEqualTo: dados!.id)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                final data = snapshot.data?.docs.first.data() as Map?;
                if (data!['profilePic'] == '') {}
                if (data['profilePic'] == '') {
                  return GestureDetector(
                    onTap: () => user?.showImagePicker(context),
                    child: ClipOval(
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 70,
                        child: Center(
                          child: Text(
                            "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 35),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () => user?.showImagePicker(context),
                    child: ClipOval(
                        child: CachedNetworkImage(
                      imageUrl: data['profilePic'],
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 70,
                        child: Center(
                          child: Text(
                            "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 35),
                          ),
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 60,
                        backgroundImage: imageProvider,
                      ),
                    )),
                  );
                }
              }
            })
        : dados != null
            ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('prefeituras/${dados['idPrefeitura']}/onibus')
                    .where('id', isEqualTo: dados['id'])
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else {
                    final data = snapshot.data?.docs.first.data() as Map?;
                    if (data!['profilePic'] == '') {}
                    if (data['profilePic'] == '') {
                      return GestureDetector(
                        onTap: () => user?.showImagePicker(context),
                        child: ClipOval(
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 70,
                            child: Center(
                              child: Text(
                                nome.length == 1
                                    ? nome[0][0].toUpperCase()
                                    : "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () => user?.showImagePicker(context),
                        child: ClipOval(
                            child: CachedNetworkImage(
                          imageUrl: data['profilePic'],
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 70,
                            child: Center(
                              child: Text(
                                "${nome[0][0].toUpperCase()}${nome[1][0].toUpperCase()}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                            ),
                          ),
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 60,
                            backgroundImage: imageProvider,
                          ),
                        )),
                      );
                    }
                  }
                })
            : Container();
  }
}
