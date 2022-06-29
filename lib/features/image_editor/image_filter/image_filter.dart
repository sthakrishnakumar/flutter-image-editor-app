import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_editor/config/constant.dart';
import 'dart:ui' as ui;

import 'package:flutter_image_editor/features/image_editor/save_image_page.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ImageFilter extends StatefulWidget {
  ImageFilter({Key? key, required this.imageData}) : super(key: key);
  Uint8List imageData;

  @override
  State<ImageFilter> createState() => _ImageFilterState();
}

class _ImageFilterState extends State<ImageFilter> {
  final GlobalKey globalKey = GlobalKey();
  final List<List<double>> filters = [
    Constant.noFilter,
    Constant.sepium,
    Constant.blackandwhite,
    Constant.coldLife,
    Constant.oldTimes,
    Constant.coldLife,
    Constant.milk,
  ];
  void convertWidgettoImage() async {
    // await Future.delayed(const Duration(milliseconds: 100));
    RenderRepaintBoundary renderRepaintBoundary =
        // ignore: use_build_context_synchronously
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 4);
    ByteData? byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData!.buffer.asUint8List();
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SaveImagePage(imageData: uint8list),
      ),
    );
  }

  File? image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Center(
            child: InkWell(
              onTap: () {},
              child: const Text('Pick Image'),
            ),
          ),
          const SizedBox(
            width: 100,
          ),
          IconButton(
            onPressed: convertWidgettoImage,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: Container(
            width: size.width,
            constraints: BoxConstraints(
              maxHeight: size.height,
              maxWidth: size.width,
            ),
            child: PageView.builder(
              itemCount: filters.length,
              itemBuilder: (context, index) {
                return ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                    filters[index],
                  ),
                  child: Image.memory(
                    widget.imageData,
                    width: size.width,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
