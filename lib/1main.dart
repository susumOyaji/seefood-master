import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  bool _imgTaken = false;
  ui.Image image;

  Future<void> _takePicture() async {
    final imageFile = await picker.getImage(
      source: ImageSource.camera,
    );
    if (imageFile == null) {
      return;
    }
    final imageByte = await imageFile.readAsBytes();
    image = await decodeImageFromList(imageByte);
    setState(() {
      _imgTaken = true;
    });
  }

  Future<void> _getImageFromGallery() async {
    final imageFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) {
      return;
    }
    final imageByte = await imageFile.readAsBytes();
    image = await decodeImageFromList(imageByte);
    setState(() {
      _imgTaken = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            _imgTaken
                ? FittedBox(
                    child: SizedBox(
                      width: image.width.toDouble(),
                      height: image.height.toDouble(),
                      child: CustomPaint(
                        painter: OriginalPainter(image),
                      ),
                    ),
                  )
                : Container(
                    width: 300,
                    height: 400,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: Text(
                      '画像が選択されていません',
                      textAlign: TextAlign.center,
                    ),
                  ),
            Row(
              children: [
                Expanded(
                  child: FlatButton.icon(
                    icon: Icon(Icons.photo_camera),
                    label: Text('カメラ'),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: _takePicture,
                  ),
                ),
                Expanded(
                  child: FlatButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: Text('ギャラリー'),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: _getImageFromGallery,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OriginalPainter extends CustomPainter {
  final ui.Image image;
  OriginalPainter(this.image);

  @override
  void paint(ui.Canvas canvas, Size size) {
    final paint = Paint();
    if (image != null) {
      canvas.drawImage(image, Offset(0, 0), paint);
    }
    paint.color = Colors.red;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, paint);
  }

  @override
  bool shouldRepaint(covariant OriginalPainter oldDelegate) => false;
}
