import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers.dart';

/// Muestra una foto: en el teléfono desde su carpeta; en la web, descargada de
/// Google Drive (con un indicador mientras llega).
class PhotoImage extends ConsumerWidget {
  const PhotoImage(this.photo, {super.key, this.width, this.height, this.fit, this.cacheWidth});
  final Photo photo;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;

  Widget _broken() => SizedBox(width: width, height: height, child: const Icon(Icons.broken_image));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) {
      return Image.file(
        ref.watch(photoStoreProvider).file(photo.localPath),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => _broken(),
      );
    }
    return ref
        .watch(photoBytesProvider(photo))
        .when(
          data: (bytes) => bytes == null
              ? _broken()
              : Image.memory(
                  bytes,
                  width: width,
                  height: height,
                  fit: fit,
                  cacheWidth: cacheWidth,
                  errorBuilder: (_, _, _) => _broken(),
                ),
          loading: () => SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
          error: (_, _) => _broken(),
        );
  }
}
