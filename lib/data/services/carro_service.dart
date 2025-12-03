import 'package:firebase_database/firebase_database.dart';
import '../../models/carro.dart';


class CarroService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<CarroModel> getCarroStream() {
    return _dbRef.child('carro').onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        return CarroModel.fromMap(data);
      }
      return CarroModel();
    });
  }


  Future<void> updateCarro(CarroModel carro) async {
    try {
      await _dbRef.child('carro').update(carro.toMap());
    } catch (e) {
      print("Erro ao enviar dados para o Firebase: $e");
    }
  }
}