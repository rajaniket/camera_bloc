import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// Takes a screenshot of a widget identified by the provided [key].
Future<Uint8List> takeCameraScreenshot({
  required GlobalKey key,
}) async {
  try {
    // Find the RenderRepaintBoundary associated with the provided key
    RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  } catch (e) {
    // If an error occurs during the screenshot process, return an error future
    return Future.error(e);
  }
}
