import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/services/carro_service.dart';
import '../../models/carro.dart';


class CarroViewModel extends ChangeNotifier {
  final CarroService _service;

  CarroModel _state = CarroModel();
  CarroModel get state => _state;

  bool _isListening = false;
  bool get isListening => _isListening;

  final stt.SpeechToText _speech = stt.SpeechToText();


  CarroViewModel(this._service);


  void init() {
    _service.getCarroStream().listen((novoModelo) {
      _state = novoModelo;
      notifyListeners();
    });
  }



  void updateJoystick(double x, double y) {
    if (_state.joystickX == x && _state.joystickY == y) return;
    _state.joystickX = x;
    _state.joystickY = y;
    _state.modoDirecao = "manual";
    _syncService();
  }

  void toggleLuz() {
    _state.luz = !_state.luz;
    _syncService();
  }

  void toggleTurbo() {
    _state.turbo = !_state.turbo;
    if (_state.turbo) _state.stealth = false;
    _syncService();
  }

  void toggleStealth() {
    _state.stealth = !_state.stealth;
    if (_state.stealth) {
      _state.turbo = false;
      _state.luz = false;
    }
    _syncService();
  }

  void setDestinoAutomatico(double x, double y) {
    _state.destinoX = x;
    _state.destinoY = y;
    _state.modoDirecao = "automatico";
    _syncService();
  }

  Future<void> listenVoiceCommand() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        notifyListeners();
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              _processVoiceCommand(val.recognizedWords);
              _isListening = false;
              notifyListeners();
            }
          },
          localeId: 'pt_BR',
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      notifyListeners();
    }
  }

  void _processVoiceCommand(String command) {
    String cmd = command.toLowerCase();

    if (cmd.contains("luz") || cmd.contains("farol")) {
      if (cmd.contains("ligar") || cmd.contains("acender")) _state.luz = true;
      if (cmd.contains("desligar") || cmd.contains("apagar")) _state.luz = false;
    }

    if (cmd.contains("turbo")) {
      _state.turbo = true;
      _state.stealth = false;
    }

    if (cmd.contains("stealth") || cmd.contains("furtivo")) {
      _state.stealth = true;
      _state.turbo = false;
      _state.luz = false;
    }

    if (cmd.contains("parar")) {
      _state.joystickX = 0;
      _state.joystickY = 0;
      _state.modoDirecao = "manual";
      _state.turbo = false;
    }
    _syncService();
  }

  void _syncService() {
    _service.updateCarro(_state);
    notifyListeners();
  }
}