class CarroModel {
  double destinoX;
  double destinoY;
  double distancia;
  double joystickX;
  double joystickY;
  bool luz; // Luz interna (Cabine)
  bool farol; // Faróis dianteiros
  String modoDirecao;
  bool stealth;
  bool turbo;

  bool ignicao;
  double angulo;

  double? latRef;
  double? lngRef;

  CarroModel({
    this.destinoX = 0,
    this.destinoY = 0,
    this.distancia = 0,
    this.joystickX = 0,
    this.joystickY = 0,
    this.luz = false,
    this.farol = false,
    this.modoDirecao = "manual",
    this.stealth = false,
    this.turbo = false,
    this.ignicao = false,
    this.angulo = 0,
    this.latRef,
    this.lngRef,
  });

  // Método usado pelo Service para ler dados do Firebase
  factory CarroModel.fromMap(Map<dynamic, dynamic> map) {
    return CarroModel(
      destinoX: (map['destinoX'] ?? 0).toDouble(),
      destinoY: (map['destinoY'] ?? 0).toDouble(),
      distancia: (map['distancia'] ?? 0).toDouble(),
      joystickX: (map['joystickX'] ?? 0).toDouble(),
      joystickY: (map['joystickY'] ?? 0).toDouble(),
      luz: map['luz'] ?? false,
      farol: map['farol'] ?? false,
      modoDirecao: map['modoDirecao'] ?? "manual",
      stealth: map['stealth'] ?? false,
      turbo: map['turbo'] ?? false,
      ignicao: map['ignicao'] ?? false,
      angulo: (map['angulo'] ?? 0).toDouble(),
      latRef: map['latRef'] != null ? (map['latRef']).toDouble() : null,
      lngRef: map['lngRef'] != null ? (map['lngRef']).toDouble() : null,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'destinoX': destinoX,
      'destinoY': destinoY,
      'distancia': distancia,
      'joystickX': joystickX,
      'joystickY': joystickY,
      'luz': luz,
      'farol': farol,
      'modoDirecao': modoDirecao,
      'stealth': stealth,
      'turbo': turbo,
      'ignicao': ignicao,
      'angulo': angulo,
      'latRef': latRef,
      'lngRef': lngRef,
    };
  }
}