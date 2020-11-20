import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_customvision/flutter_customvision.dart';
import 'package:flutter_customvision_example/model.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImagePrediction _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool _loadResult = false;
  String _model = objectDetection;

  @override
  void initState() {
    super.initState();
    loadObjectDetection();
  }

  Future<void> loadObjectDetection() async {
    bool result = false;
    try {
      result = await FlutterCustomvision.loadClassification(
              coreML: "assets/CoreML/Classifier/cvexport.manifest") &&
          await FlutterCustomvision.loadObjectDetection(
              coreML: "assets/CoreML/ObjectDetector/cvexport.manifest");
      print("Load result: " + (result ? 'OK' : 'NG'));
    } on PlatformException {
      print("Load error");
    }

    setState(() {
      _loadResult = result;
    });
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  setModel(String model) {
    setState(() {
      _model = model;
    });
    // print(model);
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    if (!_loadResult) {
      return Container();
    }
    return Scaffold(
      body: Stack(children: [
        Camera(
          widget.cameras,
          setRecognitions,
          _model,
        ),
        _recognitions != null
            ? BndBox(
                _recognitions,
                math.max(_imageHeight, _imageWidth),
                math.min(_imageHeight, _imageWidth),
                screen.height,
                screen.width,
                _model,
              )
            : Container(),
        Container(
          padding: const EdgeInsets.all(45.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                onPressed: () => setModel(objectDetection),
                child: const Text(objectDetection),
                color: _model == objectDetection ? Colors.green : Colors.grey,
              ),
              RaisedButton(
                onPressed: () => setModel(classification),
                child: const Text(classification),
                color: _model == classification ? Colors.green : Colors.grey,
              ),
            ],
          ),
        )
      ]),
    );
  }
}
