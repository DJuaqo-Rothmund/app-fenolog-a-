import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;

/// Ancho máximo de una foto dentro del PDF (suficiente para ver la canopia y el
/// detalle en una hoja Carta, sin que el archivo pese demasiado para WhatsApp).
const reportPhotoWidth = 900;

/// Reduce una foto para el informe: el equipo la decodifica y achica (rápido)
/// y luego se comprime a JPEG en otro isolate (en la web, en el mismo hilo).
/// Devuelve `null` si no se puede leer.
Future<Uint8List?> shrinkPhotoForReport(Uint8List original) async {
  try {
    final codec = await ui.instantiateImageCodec(original, targetWidth: reportPhotoWidth);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final w = image.width, h = image.height;
    image.dispose();
    codec.dispose();
    if (rgba == null) return null;
    return await _encodeJpegInIsolate(rgba.buffer.asUint8List(), w, h);
  } catch (_) {
    return null;
  }
}

Future<Uint8List> _encodeJpegInIsolate(Uint8List rgba, int w, int h) async =>
    kIsWeb ? encodeReportJpeg(rgba, w, h) : Isolate.run(() => encodeReportJpeg(rgba, w, h));

/// Comprime píxeles RGBA a JPEG (calidad 72).
Uint8List encodeReportJpeg(Uint8List rgba, int w, int h) {
  final image = img.Image.fromBytes(width: w, height: h, bytes: rgba.buffer, numChannels: 4);
  return img.encodeJpg(image, quality: 72);
}
