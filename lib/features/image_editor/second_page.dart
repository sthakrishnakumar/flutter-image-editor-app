// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final Uint8List imageData;
  const SecondPage({
    Key? key,
    required this.imageData,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: size.height,
          maxWidth: size.width,
        ),
        child: Image.memory(imageData),
      ),
    );
  }
}
