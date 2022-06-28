import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor/features/edit_image/edit_screen.dart';
import 'package:image_picker/image_picker.dart';

class SelectImage extends StatefulWidget {
  const SelectImage({Key? key}) : super(key: key);

  @override
  State<SelectImage> createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  File? image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      Future.delayed(const Duration(seconds: 0)).then(
        (value) => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditImage(
              arguments: [image],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                getImage();
              },
              child: const Text('Pick Image'),
            ),
          ),
        ],
      ),
    );
  }
}
