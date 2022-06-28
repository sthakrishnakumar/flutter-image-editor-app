import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class EditImage extends StatefulWidget {
  EditImage({Key? key, required this.arguments}) : super(key: key);
  List arguments;

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  double sat = 1;
  double bright = 0;
  double con = 1;

  final defaultColorMatrix = const <double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0
  ];
  List<double> calculateSaturationMatrix(double saturation) {
    final m = List<double>.from(defaultColorMatrix);
    final invSat = 1 - saturation;
    final R = 0.213 * invSat;
    final G = 0.715 * invSat;
    final B = 0.072 * invSat;

    m[0] = R + saturation;
    m[1] = G;
    m[2] = B;
    m[5] = R;
    m[6] = G + saturation;
    m[7] = B;
    m[10] = R;
    m[11] = G;
    m[12] = B + saturation;

    return m;
  }

  List<double> calculateContrastMatrix(double contrast) {
    final m = List<double>.from(defaultColorMatrix);
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return m;
  }

  File? image;
  @override
  void initState() {
    super.initState();
    image = widget.arguments[0];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Image'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  sat = 1;
                  bright = 0;
                  con = 1;
                });
              },
              icon: const Icon(Icons.settings_backup_restore),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.check),
            ),
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: buildImage(),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: SliderTheme(
                  data: const SliderThemeData(
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        _buildSaturation(),
                        const Spacer(flex: 1),
                        _buildBrightness(),
                        const Spacer(flex: 1),
                        _buildContrast(),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage() {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
        calculateContrastMatrix(con),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          calculateSaturationMatrix(sat),
        ),
        child: ExtendedImage(
          image: ExtendedFileImageProvider(image!),
          color: bright > 0
              ? Colors.white.withOpacity(bright)
              : Colors.black.withOpacity(-bright),
          colorBlendMode: bright > 0 ? BlendMode.lighten : BlendMode.darken,
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          extendedImageEditorKey: editorKey,
          mode: ExtendedImageMode.editor,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSaturation() {
    return Row(
      children: [],
    );
  }

  Widget _buildBrightness() {
    return Row();
  }

  Widget _buildContrast() {
    return Row();
  }
}
