import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// Cámara y galería. Las fotos se reducen a 2048 px y calidad 85 para ahorrar
/// espacio sin perder el detalle necesario para identificar estadios.
class PhotoPicker {
  final _picker = ImagePicker();

  Future<List<String>> fromCamera() async {
    final f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 2048, maxHeight: 2048, imageQuality: 85);
    return f == null ? const [] : [f.path];
  }

  Future<List<String>> fromGallery() async {
    final files = await _picker.pickMultiImage(maxWidth: 2048, maxHeight: 2048, imageQuality: 85);
    return [for (final f in files) f.path];
  }
}

class LocationFix {
  const LocationFix(this.lat, this.lon, this.accuracyM);
  final double lat;
  final double lon;
  final double accuracyM;
}

class LocationException implements Exception {
  LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// GPS del teléfono (funciona sin internet).
class LocationService {
  Future<LocationFix> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException('El GPS está apagado. Actívalo en los ajustes del teléfono.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw LocationException('La app no tiene permiso para usar la ubicación.');
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 45)),
    );
    return LocationFix(p.latitude, p.longitude, p.accuracy);
  }
}

final photoPickerProvider = Provider((ref) => PhotoPicker());
final locationServiceProvider = Provider((ref) => LocationService());
