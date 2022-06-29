// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class SaveImagePage extends StatefulWidget {
  final Uint8List imageData;

  const SaveImagePage({
    Key? key,
    required this.imageData,
  }) : super(key: key);

  @override
  State<SaveImagePage> createState() => _SaveImagePageState();
}

class _SaveImagePageState extends State<SaveImagePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Widget imageWidget() => Container(
          constraints: BoxConstraints(
            maxHeight: size.height,
            maxWidth: size.width,
          ),
          child: Image.memory(
            widget.imageData,
            fit: BoxFit.contain,
            width: size.width,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
        actions: [
          IconButton(
            onPressed: () {
              saveandShare(widget.imageData);
            },
            icon: const Icon(Icons.share),
          ),
          ElevatedButton(
            onPressed: () {
              // final image = await controller.captureFromWidget(imageWidget());
              if (widget.imageData.isNotEmpty) {
                saveImage(widget.imageData);
              }
            },
            child: const Text('Save Image'),
          )
        ],
      ),
      body: Center(
        child: imageWidget(),
      ),
    );
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'Image $time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).clearSnackBars();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image Saved Succesfully'),
      ),
    );
    return result['filePath'];
  }

  Future saveandShare(Uint8List bytes) async {
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-')
        .toLowerCase();
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter-$time.png');
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path]);
  }
}
