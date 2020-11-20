import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_customvision/flutter_customvision.dart';
import 'package:flutter_customvision_example/model.dart';

class BndBox extends StatelessWidget {
  final ImagePrediction results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String _model;

  BndBox(
    this.results,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW,
    this._model,
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBoxes() {
      return results.predictions.map((re) {
        print("${re.tagName} ${(re.probability * 100).toStringAsFixed(0)}%");
        var _x = re.boundingBox.left;
        var _w = re.boundingBox.width;
        var _y = re.boundingBox.top;
        var _h = re.boundingBox.height;
        var scaleW, scaleH, x, y, w, h;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re.tagName} ${(re.probability * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    List<Widget> _renderStrings() {
      double offset = 100;
      return results.predictions.map((re) {
        offset = offset + 14;
        return Positioned(
          left: 10,
          top: offset,
          width: screenW,
          height: screenH,
          child: Text(
            "${re.tagName} ${(re.probability * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList();
    }

    return Stack(
      children: _model == objectDetection ? _renderBoxes() : _renderStrings(),
    );
  }
}
