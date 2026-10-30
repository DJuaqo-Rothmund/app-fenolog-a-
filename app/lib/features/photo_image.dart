import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers.dart';

/// Bytes de una foto que está en el servidor (navegador, o teléfono que aún
/// no la descarga). Nulo si no hay sesión o la foto no se ha subido.
final remotePhotoProvider = FutureProvider.family<Uint8List?, String>((ref, photoId) async {
  final engine = ref.watch(syncEngineProvider);
  final session = await engine.session();
  if (session == null) return null;
  final bytes = await engine.api(session).getPhoto(photoId);
  return bytes == null ? null : Uint8List.fromList(bytes);
});

/// Muestra una foto: el archivo del teléfono si está, si no la del servidor.
class PhotoImage extends ConsumerWidget {
  const PhotoImage({super.key, required this.photo, this.width, this.height, this.fit, this.cacheWidth});
  final Photo photo;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget placeholder(IconData icon) => SizedBox(
      width: width,
      height: height,
      child: Center(child: Icon(icon)),
    );
    if (!kIsWeb && photo.localPath.isNotEmpty && File(photo.localPath).existsSync()) {
      return Image.file(
        File(photo.localPath),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => placeholder(Icons.broken_image),
      );
    }
    return ref
        .watch(remotePhotoProvider(photo.id))
        .when(
          data: (bytes) => bytes == null
              ? placeholder(Icons.cloud_off_outlined)
              : Image.memory(bytes, width: width, height: height, fit: fit, cacheWidth: cacheWidth),
          loading: () => placeholder(Icons.cloud_download_outlined),
          error: (_, _) => placeholder(Icons.cloud_off_outlined),
        );
  }
}
