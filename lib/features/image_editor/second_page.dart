// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class SecondPage extends StatefulWidget {
  final Uint8List imageData;
  const SecondPage({
    Key? key,
    required this.imageData,
  }) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final controller = ScreenshotController();
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

    return Screenshot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('title'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final image = await controller.captureFromWidget(imageWidget());
              },
              child: const Text('Save Image'),
            )
          ],
        ),
        body: imageWidget(),
      ),
    );
  }
}
