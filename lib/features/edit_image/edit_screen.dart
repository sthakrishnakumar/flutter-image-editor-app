import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_editor/features/image_editor/image_filter/image_filter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class EditImage extends StatefulWidget {
  EditImage({Key? key, required this.arguments}) : super(key: key);
  List arguments;

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  final GlobalKey globalKey = GlobalKey();
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

  void convertWidgettoImage() async {
    // await Future.delayed(const Duration(milliseconds: 100));
    RenderRepaintBoundary renderRepaintBoundary =
        // ignore: use_build_context_synchronously
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 4);
    ByteData? byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData!.buffer.asUint8List();
    // saveImage(uint8list);

    //ignore: use_build_context_synchronously
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            // SaveImagePage(imageData: uint8list)
            ImageFilter(imageData: uint8list),
      ),
    );
  }

  void convertWidget() async {
    // await Future.delayed(const Duration(milliseconds: 100));
    RenderRepaintBoundary renderRepaintBoundary =
        // ignore: use_build_context_synchronously
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 4);
    ByteData? byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8list = byteData!.buffer.asUint8List();
    saveImage(uint8list);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // bottomNavigationBar: bottomNavBar(),
        appBar: AppBar(
          title: const Text('Edit Image'),
          actions: [
            IconButton(
              onPressed: convertWidget,
              icon: const Icon(Icons.save),
            ),
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
              onPressed: convertWidgettoImage,
              icon: const Icon(Icons.check),
            ),
          ],
        ),
        body: Container(
          color: Colors.green,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              // shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 10,
                ),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(flex: 1),
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
      ),
    );
  }

  // Future saveImage() async {
  //   final ExtendedImageEditorState state = editorKey.currentState!;
  //   final Uint8List img = state.rawImageData;
  //   Future.delayed(const Duration(seconds: 1)).then(
  //     (value) => Navigator.pushReplacement(
  //       context,
  //       CupertinoPageRoute(
  //         builder: (context) => SaveImagePage(
  //           imageData: img,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'Image $time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image Saved Succesfully'),
      ),
    );
    return result['filePath'];
  }

  Future saveandShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/Nishant.png');
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path]);
  }

  Widget buildImage() {
    return RepaintBoundary(
      key: globalKey,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          calculateContrastMatrix(con),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(
            calculateSaturationMatrix(sat),
          ),
          child: ExtendedImage(
            alignment: Alignment.center,
            image: ExtendedFileImageProvider(image!),
            color: bright > 0
                ? Colors.white.withOpacity(bright)
                : Colors.black.withOpacity(-bright),
            colorBlendMode: bright > 0 ? BlendMode.lighten : BlendMode.darken,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // extendedImageEditorKey: editorKey,
            // mode: ExtendedImageMode.editor,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget bottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).primaryColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.flip,
            color: Colors.white,
          ),
          label: 'Flip',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.rotate_left,
            color: Colors.white,
          ),
          label: 'Rotate left',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.rotate_right,
            color: Colors.white,
          ),
          label: 'Rotate right',
        ),
      ],
      onTap: (int index) {
        switch (index) {
          case 0:
            flip();
            break;
          case 1:
            rotate(false);
            break;
          case 2:
            rotate(true);
            break;
        }
      },
      currentIndex: 0,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).primaryColor,
    );
  }

  void flip() {
    editorKey.currentState!.flip();
  }

  void rotate(bool right) {
    editorKey.currentState!.rotate(right: right);
  }

  Widget _buildSaturation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.brush,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Saturation",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: 'sat : ${sat.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                sat = value;
              });
            },
            divisions: 50,
            value: sat,
            min: 0,
            max: 2,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(sat.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildBrightness() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.brightness_4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Brightness",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: bright.toStringAsFixed(2),
            onChanged: (double value) {
              setState(() {
                bright = value;
              });
            },
            divisions: 50,
            value: bright,
            min: -1,
            max: 1,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(bright.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildContrast() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.color_lens,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Contrast",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: 'con : ${con.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                con = value;
              });
            },
            divisions: 50,
            value: con,
            min: 0,
            max: 4,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(con.toStringAsFixed(2)),
        ),
      ],
    );
  }
}
