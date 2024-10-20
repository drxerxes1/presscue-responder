import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<ui.Image> loadImageFromAssets(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}
