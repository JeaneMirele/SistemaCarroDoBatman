import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../view_models/carro_view_model.dart';


class BatScreen extends StatelessWidget {
  const BatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CarroViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("BAT-REMOTE LINK"),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                border: Border.all(color: vm.state.modoDirecao == 'automatico' ? Colors.cyan : Colors.grey),
                borderRadius: BorderRadius.circular(4)
            ),
            child: Text(
              vm.state.modoDirecao.toUpperCase(),
              style: TextStyle(
                  color: vm.state.modoDirecao == 'automatico' ? Colors.cyan : Colors.grey,
                  fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildStatusPanel(vm),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSpecialFunctions(vm),
                        const SizedBox(height: 20),
                        Expanded(child: _buildRadarMap(vm, context)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("CONTROLE MANUAL", style: TextStyle(color: Colors.white54, letterSpacing: 2)),
                        const SizedBox(height: 30),
                        Joystick(
                          mode: JoystickMode.all,
                          listener: (details) => vm.updateJoystick(details.x, details.y * -1),
                          base: Container(
                            width: 200, height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                    color: vm.state.turbo ? Colors.red.withOpacity(0.5) : const Color(0xFFFFD700).withOpacity(0.2),
                                    blurRadius: 20, spreadRadius: 5
                                )
                              ],
                              border: Border.all(color: const Color(0xFF333333), width: 4),
                            ),
                          ),
                          stick: Container(
                            width: 60, height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF444444),
                            ),
                            child: const Icon(Icons.gamepad, color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildVoiceControl(vm),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(CarroViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statusItem(Icons.radar, "DISTÂNCIA", "${vm.state.distancia.toStringAsFixed(1)} cm"),
          _statusItem(Icons.speed, "MOTOR", vm.state.joystickY == 0 ? "PARADO" : "${(vm.state.joystickY * 100).abs().toInt()}%"),
          _statusItem(Icons.bolt, "STATUS", vm.state.stealth ? "FURTIVO" : (vm.state.turbo ? "TURBO MAX" : "NORMAL"),
              color: vm.state.stealth ? Colors.blueGrey : (vm.state.turbo ? Colors.redAccent : Colors.amber)
          ),
        ],
      ),
    );
  }

  Widget _statusItem(IconData icon, String label, String value, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
      ],
    );
  }

  Widget _buildSpecialFunctions(CarroViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BatButton(label: "FARÓIS", isActive: vm.state.luz, icon: Icons.lightbulb, activeColor: Colors.yellow, onTap: vm.toggleLuz),
        _BatButton(label: "TURBO", isActive: vm.state.turbo, icon: Icons.local_fire_department, activeColor: Colors.redAccent, onTap: vm.toggleTurbo),
        _BatButton(label: "STEALTH", isActive: vm.state.stealth, icon: Icons.visibility_off, activeColor: Colors.cyanAccent, onTap: vm.toggleStealth),
      ],
    );
  }

  Widget _buildRadarMap(CarroViewModel vm, BuildContext context) {
    return Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: Text("NAVEGAÇÃO", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    double mapX = (details.localPosition.dx / constraints.maxWidth) * 100;
                    double mapY = (details.localPosition.dy / constraints.maxHeight) * 100;
                    vm.setDestinoAutomatico(mapX, mapY);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                        image: const DecorationImage(
                          image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Radial_grid_graph.svg/1024px-Radial_grid_graph.svg.png"),
                          opacity: 0.2, fit: BoxFit.cover,
                        )
                    ),
                    child: Stack(
                      children: [
                        if (vm.state.modoDirecao == 'automatico')
                          Positioned(
                            left: (vm.state.destinoX / 100) * constraints.maxWidth - 15,
                            top: (vm.state.destinoY / 100) * constraints.maxHeight - 15,
                            child: const Icon(Icons.location_on, color: Colors.cyanAccent, size: 30),
                          ),
                      ],
                    ),
                  ),
                );
              }
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceControl(CarroViewModel vm) {
    return GestureDetector(
      onLongPress: vm.listenVoiceCommand,
      onTap: vm.listenVoiceCommand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: vm.isListening ? Colors.red : const Color(0xFF2C2C2C),
            boxShadow: [if (vm.isListening) BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)]
        ),
        child: Icon(vm.isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 32),
      ),
    );
  }
}

class _BatButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  const _BatButton({required this.label, required this.isActive, required this.icon, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
              border: Border.all(color: isActive ? activeColor : Colors.grey.withOpacity(0.3), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isActive ? activeColor : Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? activeColor : Colors.grey))
        ],
      ),
    );
  }
}