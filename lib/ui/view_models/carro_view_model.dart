import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/services/carro_service.dart';
import '../../models/carro.dart';

class CarroViewModel extends ChangeNotifier {
  final CarroService _service;
  final stt.SpeechToText _speech = stt.SpeechToText();

  CarroModel _state = CarroModel();
  CarroModel get state => _state;

  bool _isListening = false;
  bool get isListening => _isListening;

  CarroViewModel(this._service);

  void init() {
    _service.getCarroStream().listen((novoModelo) {
      _state = novoModelo;
      notifyListeners();
    });
    _resetarEstadoInicial();
  }

  void _resetarEstadoInicial() {
    _state.ignicao = false;
    _state.luz = false;
    _state.turbo = false;
    _state.stealth = false;
    _state.joystickX = 0;
    _state.joystickY = 0;
    _state.modoDirecao = "manual";


    _syncService();
  }

  void toggleIgnicao() {
    _state.ignicao = !_state.ignicao;

    if (!_state.ignicao) {
      _state.turbo = false;
      _state.luz = false;
      _state.stealth = false;
      _state.joystickX = 0;
      _state.joystickY = 0;
      _state.modoDirecao = "manual";
    }

    _syncService();
  }

  void updateJoystick(double x, double y) {
    if (!_state.ignicao) return;
    if (_state.joystickX == x && _state.joystickY == y) return;
    _state.joystickX = x;
    _state.joystickY = y;
    _state.modoDirecao = "manual";
    _syncService();
  }

  void toggleLuz() {
    if (!_state.ignicao) return;
    _state.luz = !_state.luz;
    if (_state.luz) _state.stealth = false;
    _syncService();
  }

  void toggleTurbo() {
    if (!_state.ignicao) return;
    _state.turbo = !_state.turbo;
    if (_state.turbo) _state.stealth = false;
    _syncService();
  }

  void toggleStealth() {
    if (!_state.ignicao) return;
    _state.stealth = !_state.stealth;

    if (_state.stealth) {
      _state.turbo = false;
      _state.luz = false;
    }
    _syncService();
  }

  void setDestinoAutomatico(double x, double y) {
    if (!_state.ignicao) return;
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


    if (cmd.contains("ligar carro") || cmd.contains("partida")) {
      if (!_state.ignicao) toggleIgnicao();
    }
    if (cmd.contains("desligar carro")) {
      if (_state.ignicao) toggleIgnicao();
    }

    if (!_state.ignicao) return;

    if (cmd.contains("luz") || cmd.contains("farol")) {
      if (cmd.contains("ligar")) _state.luz = true;
      if (cmd.contains("desligar")) _state.luz = false;
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
    }

    _syncService();
  }

  void _syncService() {
    _service.updateCarro(_state);
    notifyListeners();
  }
}