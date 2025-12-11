import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Serviços de localização não estão habilitados.
      return Future.error('Serviços de localização estão desabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissões negadas.
        return Future.error('Permissões de localização foram negadas');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissões negadas para sempre.
      return Future.error(
          'Permissões de localização foram negadas permanentemente, não podemos solicitar permissões.');
    }

    // Se as permissões forem concedidas, obtenha a posição atual.
    return await Geolocator.getCurrentPosition();
  }
}
