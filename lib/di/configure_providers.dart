import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/services/carro_service.dart';
import '../data/services/location_service.dart';
import '../ui/view_models/carro_view_model.dart';



List<SingleChildWidget> get appProviders {
  return [

    Provider<CarroService>(
      create: (_) => CarroService(),
    ),

    Provider<LocationService>(
      create: (_) => LocationService(),
    ),

    ChangeNotifierProvider<CarroViewModel>(
      create: (context) {
        final service = context.read<CarroService>();
        final locationService = context.read<LocationService>();
        final viewModel = CarroViewModel(service, locationService);
        viewModel.init();
        return viewModel;
      },
    ),
  ];
}