import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../view_models/carro_view_model.dart';

class ManualControlView extends StatelessWidget {
  const ManualControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CarroViewModel>(context);

    // Lógica do botão trazida para cá
    final bool motorLigado = vm.state.ignicao;
    final Color corBotao = motorLigado ? Colors.redAccent : const Color(0xFFFFD700);
    final Color corIcone = motorLigado ? Colors.white : Colors.black;
    final String textoBotao = motorLigado ? "DESLIGAR MOTOR" : "DAR PARTIDA";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // --- Botões de Toggle (Luz, Turbo, Stealth) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BatButton(
                  label: "CABINE",
                  isActive: vm.state.luz,
                  icon: Icons.lightbulb,
                  activeColor: Colors.white,
                  onTap: vm.toggleLuz),
              _BatButton(
                  label: "TURBO",
                  isActive: vm.state.turbo,
                  icon: Icons.local_fire_department,
                  activeColor: Colors.redAccent,
                  onTap: vm.toggleTurbo),
              _BatButton(
                  label: "STEALTH",
                  isActive: vm.state.stealth,
                  icon: Icons.visibility_off,
                  activeColor: Colors.cyanAccent,
                  onTap: vm.toggleStealth),
            ],
          ),
        ),

        const Spacer(),

        // --- Joystick ---
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5)
            ],
          ),
          child: Joystick(
            mode: JoystickMode.all,
            listener: (details) => vm.updateJoystick(details.x, details.y * -1),
            base: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                      color: vm.state.turbo
                          ? Colors.red.withOpacity(0.5)
                          : const Color(0xFFFFD700).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5)
                ],
                border: Border.all(color: const Color(0xFF333333), width: 4),
              ),
            ),
            stick: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF444444),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF666666), Color(0xFF333333)]),
              ),
              child: const Icon(Icons.gamepad, color: Colors.white38),
            ),
          ),
        ),

        const Spacer(),

        // --- BOTÃO DE PARTIDA (ADICIONADO AQUI) ---
        Container(
          height: 60,
          width: 180,
          margin: const EdgeInsets.only(bottom: 30), // Espaço do fundo
          child: ElevatedButton.icon(
            onPressed: () {
              vm.toggleIgnicao();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: corBotao,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: Icon(Icons.power_settings_new, color: corIcone, size: 28),
            label: Text(
                textoBotao,
                style: TextStyle(
                    color: corIcone,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 16
                )
            ),
          ),
        ),
      ],
    );
  }
}

class _BatButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  const _BatButton(
      {required this.label,
        required this.isActive,
        required this.icon,
        required this.activeColor,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
              border: Border.all(
                  color: isActive ? activeColor : Colors.grey.withOpacity(0.3),
                  width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: isActive ? activeColor : Colors.grey, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? activeColor : Colors.grey))
        ],
      ),
    );
  }
}