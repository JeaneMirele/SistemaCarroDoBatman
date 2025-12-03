import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../view_models/carro_view_model.dart';


class ManualControlView extends StatelessWidget {
  const ManualControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CarroViewModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Painel de Funções Especiais (Luz, Turbo, Stealth)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BatButton(
                  label: "FARÓIS",
                  isActive: vm.state.luz,
                  icon: Icons.lightbulb,
                  activeColor: Colors.yellow,
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

        // Área do Joystick
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

        // Controle de Voz
        GestureDetector(
          onLongPress: vm.listenVoiceCommand,
          onTap: vm.listenVoiceCommand,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    vm.isListening ? Colors.red : const Color(0xFF2C2C2C),
                    boxShadow: [
                      if (vm.isListening)
                        BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5)
                    ]),
                child: Icon(vm.isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                  vm.isListening
                      ? "OUVINDO..."
                      : "SEGURE PARA FALAR",
                  style: const TextStyle(fontSize: 10, color: Colors.white38))
            ],
          ),
        ),
        const SizedBox(height: 30),
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
            child: Icon(icon, color: isActive ? activeColor : Colors.grey, size: 28),
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