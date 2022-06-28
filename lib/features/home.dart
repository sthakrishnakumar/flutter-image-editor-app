import 'package:flutter/material.dart';
import 'package:flutter_image_editor/config/constant.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        centerTitle: true,
      ),
      body: Column(
        children: [
         
          Image.network(Constant.flowerImage),
        ],
      ),
    );
  }
}
