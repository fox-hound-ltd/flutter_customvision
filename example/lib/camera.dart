import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

import 'package:flutter_customvision/flutter_customvision.dart';
import 'package:flutter_customvision_example/model.dart';

typedef void Callback(ImagePrediction result, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String _model;

  Camera(this.cameras, this.setRecognitions, this._model);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage image) {
          if (!isDetecting) {
            isDetecting = true;

            if (widget._model == classification) {
              FlutterCustomvision.classifyOnFrame(
                image.planes.map((plane) => plane.bytes).toList(),
                image.height,
                image.width,
                image.planes.map((plane) => plane.bytesPerRow).toList(),
                maxReturns: 10,
              ).then((recognitions) {
                widget.setRecognitions(recognitions, image.height, image.width);
                isDetecting = false;
              });
            } else {
              FlutterCustomvision.detectObjectOnFrame(
                image.planes.map((plane) => plane.bytes).toList(),
                image.height,
                image.width,
                image.planes.map((plane) => plane.bytesPerRow).toList(),
              ).then((recognitions) {
                widget.setRecognitions(recognitions, image.height, image.width);
                isDetecting = false;
              });
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
