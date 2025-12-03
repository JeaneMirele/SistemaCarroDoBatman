import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/services/carro_service.dart';
import '../ui/view_models/carro_view_model.dart';



List<SingleChildWidget> get appProviders {
  return [

    Provider<CarroService>(
      create: (_) => CarroService(),
    ),


    ChangeNotifierProvider<CarroViewModel>(
      create: (context) {
        final service = context.read<CarroService>();
        final viewModel = CarroViewModel(service);
        viewModel.init();
        return viewModel;
      },
    ),
  ];
}