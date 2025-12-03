import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/carro_view_model.dart';

class AutomaticControlView extends StatelessWidget {
  const AutomaticControlView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarroViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("SISTEMA DE NAVEGAÇÃO", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      Text(
                        vm.state.modoDirecao == 'automatico' ? "PILOTO AUTOMÁTICO ATIVO" : "AGUARDANDO COMANDO",
                        style: TextStyle(
                            color: vm.state.modoDirecao == 'automatico' ? Colors.cyanAccent : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  if (vm.state.modoDirecao == 'automatico')
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.red, size: 30),
                      onPressed: () {
                        // Zera o joystick para forçar volta ao manual/parar
                        vm.updateJoystick(0, 0);
                      },
                      tooltip: "Abortar Automático",
                    )
                ],
              ),
            ),

            // Mapa Expandido
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (details) => _handleMapTap(context, vm, details, constraints),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1518),
                        border: Border.all(
                            color: vm.state.modoDirecao == 'automatico' ? Colors.cyan : Colors.white24,
                            width: 2
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (vm.state.modoDirecao == 'automatico')
                            BoxShadow(color: Colors.cyan.withOpacity(0.15), blurRadius: 20, spreadRadius: 2)
                        ],
                        gradient: RadialGradient(
                          colors: [Colors.cyan.withOpacity(0.05), const Color(0xFF050505)],
                          radius: 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Grid
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GridPaper(
                                color: Colors.cyan.withOpacity(0.1),
                                divisions: 1,
                                subdivisions: 5,
                                interval: 100,
                              ),
                            ),
                          ),

                          // Alvo
                          if (vm.state.modoDirecao == 'automatico' || (vm.state.destinoX != 0))
                            Positioned(
                              left: (vm.state.destinoX / 100) * constraints.maxWidth - 20,
                              top: (vm.state.destinoY / 100) * constraints.maxHeight - 20,
                              child: Column(
                                children: [
                                  const Icon(Icons.gps_fixed, color: Colors.cyanAccent, size: 40),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    color: Colors.black,
                                    child: const Text("DESTINO", style: TextStyle(fontSize: 8, color: Colors.cyan)),
                                  )
                                ],
                              ),
                            ),

                          // Instrução Central se parado
                          if (vm.state.modoDirecao != 'automatico')
                            const Center(
                              child: Text(
                                "TOQUE NO GRID PARA\nENGAJAR PILOTO AUTOMÁTICO",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white24, letterSpacing: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleMapTap(BuildContext context, CarroViewModel vm, TapDownDetails details, BoxConstraints constraints) {
    double mapX = (details.localPosition.dx / constraints.maxWidth) * 100;
    double mapY = (details.localPosition.dy / constraints.maxHeight) * 100;

    mapX = mapX.clamp(0, 100);
    mapY = mapY.clamp(0, 100);

    vm.setDestinoAutomatico(mapX, mapY);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("CALCULANDO ROTA PARA: ${mapX.toInt()}, ${mapY.toInt()}"),
        backgroundColor: Colors.cyan.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}