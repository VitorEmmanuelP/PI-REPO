import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:pi/classes/profile_picture.dart';
import 'package:pi/utils/dadosUsers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/anexo.dart';

class ProfilePictureWidget extends StatefulWidget {
  const ProfilePictureWidget({Key? key}) : super(key: key);

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? arquivo;
  String? imagepath;
  ProfileImage? user;
  Map? dados;
  List<String> nome = [];

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initUser();
    loadImage();
    loadDados();
  }

  void initUser() async {
    user = ProfileImage(imgFromGallery, imgFromCamera);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => user?.showImagePicker(context),
      child: imagepath != null
          ? AnexoWidget(
              arquivo: File(imagepath!),
            )
          : CircleAvatar(
              radius: 70,
              child: Center(
                child: Text(
                  "${nome[0][0]}${nome[1][0]}",
                  style: TextStyle(color: Colors.white, fontSize: 35),
                ),
              ),
            ),
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red value (0-255)
      random.nextInt(256), // Green value (0-255)
      random.nextInt(256), // Blue value (0-255)
      1.0, // Alpha value (0-1.0)
    );
  }

  void imgFromGallery() async {
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (file == null) return;
    setState(() => arquivo = File(file.path));
    saveImage(arquivo?.path);
  }

  void imgFromCamera() async {
    final file =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (file == null) return;

    setState(() => arquivo = File(file.path));
    saveImage(arquivo?.path);
  }

  Future pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        arquivo = File(file.path);
      });
    }
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
    });
    return dados;
  }
}
