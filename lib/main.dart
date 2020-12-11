import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_core/firebase_core.dart';

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
  File _imageFile;
  List<Label> _scanResults;

  Future<void> _loadImage() async {
    setState(() {
      _imageFile = null;
    });

    final File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _scanImage(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    FirebaseVisionDetector detector = FirebaseVision.instance.labelDetector();

    final List<Label> results = await detector.detectInImage(visionImage);

    setState(() {
      _scanResults = results;
    });
  }

  List<Widget> buildImage(BuildContext context) {
    if (_imageFile == null) {
      return <Widget>[
        Text(
          'Select your photo from Floating Action Button.',
        ),
      ];
    } else {
      String labelString = "";
      if (_scanResults != null) {
        for (Label label in _scanResults) {
          labelString += 'Label: ${label.label}, '
              'Confidence: ${label.confidence.toStringAsFixed(2)}\n';
        }
      }
      return <Widget>[
        new Image.file(_imageFile),
        new Text(labelString),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buildImage(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadImage,
        tooltip: 'Load Image',
        child: Icon(Icons.add),
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
