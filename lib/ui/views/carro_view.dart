import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/carro_view_model.dart';
import 'controle_manual_view.dart';
import 'mapa_view.dart';

class BatScreen extends StatefulWidget {
  const BatScreen({super.key});

  @override
  State<BatScreen> createState() => _BatScreenState();
}

class _BatScreenState extends State<BatScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ManualControlView(),
    const AutomaticControlView(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CarroViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("BAT-REMOTE LINK"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _buildTelemetryBar(vm),
        ),
      ),

      // Aqui alternamos as telas baseado no índice selecionado
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFFFD700), // Amarelo Batman
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: "MANUAL",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "AUTO PILOT",
          ),
        ],
      ),
    );
  }

  // Barra de status que fica sempre visível no topo
  Widget _buildTelemetryBar(CarroViewModel vm) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _telemetryItem("DIST", "${vm.state.distancia.toInt()}cm", Icons.radar),
          Container(width: 1, height: 20, color: Colors.white10),
          _telemetryItem("MODO", vm.state.modoDirecao.toUpperCase(), Icons.settings_remote,
              color: vm.state.modoDirecao == 'automatico' ? Colors.cyan : Colors.amber),
        ],
      ),
    );
  }

  Widget _telemetryItem(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text("$label: ", style: const TextStyle(color: Colors.white38, fontSize: 12)),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}