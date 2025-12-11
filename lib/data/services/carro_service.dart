import 'package:firebase_database/firebase_database.dart';
import '../../models/carro.dart';

class CarroService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();


  Stream<CarroModel> getCarroStream() {
    return _dbRef.child('carro').onValue.map((event) {
      final data = event.snapshot.value;


      if (data != null && data is Map) {

        return CarroModel.fromMap(Map<dynamic, dynamic>.from(data));
      }
      return CarroModel();
    });
  }


  Future<void> updateCarro(CarroModel carro) async {
    try {


      final Map<String, dynamic> comandos = {
        'ignicao': carro.ignicao,
        'joystickX': carro.joystickX,
        'joystickY': carro.joystickY,
        'luz': carro.luz,
        'farol': carro.farol,
        'turbo': carro.turbo,
        'stealth': carro.stealth,
        'modoDirecao': carro.modoDirecao,
        'destinoX': carro.destinoX,
        'destinoY': carro.destinoY,
        'latRef': carro.latRef,
        'lngRef': carro.lngRef,
      };

      await _dbRef.child('carro').update(comandos);

    } catch (e) {
      print("Erro ao enviar dados para o Firebase: $e");
    }
  }
}