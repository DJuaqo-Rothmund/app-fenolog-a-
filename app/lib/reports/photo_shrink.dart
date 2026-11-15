import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

/// Ancho máximo de una foto dentro del PDF (suficiente para ver la canopia y el
/// detalle en una hoja Carta, sin que el archivo pese demasiado para WhatsApp).
const reportPhotoWidth = 900;

/// Reduce una foto para el informe: el teléfono la decodifica y achica (rápido)
/// y luego se comprime a JPEG en otro isolate. Devuelve `null` si no se puede leer.
Future<Uint8List?> shrinkPhotoForReport(File file) async {
  try {
    if (!await file.exists()) return null;
    final codec = await ui.instantiateImageCodec(await file.readAsBytes(), targetWidth: reportPhotoWidth);
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

Future<Uint8List> _encodeJpegInIsolate(Uint8List rgba, int w, int h) => Isolate.run(() => encodeReportJpeg(rgba, w, h));

/// Comprime píxeles RGBA a JPEG (calidad 72).
Uint8List encodeReportJpeg(Uint8List rgba, int w, int h) {
  final image = img.Image.fromBytes(width: w, height: h, bytes: rgba.buffer, numChannels: 4);
  return img.encodeJpg(image, quality: 72);
}
