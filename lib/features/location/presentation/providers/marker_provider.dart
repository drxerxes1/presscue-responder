// marker_provider.dart
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import '../../domain/entities/marker.dart';


final markerProvider = FutureProvider<List<MarkerData>>((ref) async {
  final ByteData data = await rootBundle.load(AppIcons.testPic2);
  final Uint8List bytes = data.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  return [
    MarkerData(
      latitude: 6.21888861,
      longitude: 125.077,
      imageProvider: Future.value(image),
    ),
    // Add more markers as needed
  ];
});
