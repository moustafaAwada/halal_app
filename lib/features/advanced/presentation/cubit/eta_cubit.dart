import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/eta_info.dart';
import '../../domain/usecases/get_high_demand_eta.dart';

part 'eta_state.dart';

class EtaCubit extends Cubit<EtaState> {
  EtaCubit({required GetHighDemandEtaUseCase getHighDemandEtaUseCase})
      : _getHighDemandEtaUseCase = getHighDemandEtaUseCase,
        super(const EtaInitial());

  final GetHighDemandEtaUseCase _getHighDemandEtaUseCase;

  Future<void> load() async {
    emit(const EtaLoading());

    final result = await _getHighDemandEtaUseCase(const NoParams());

    result.fold(
      (failure) => emit(EtaError(message: failure.message)),
      (info) => emit(EtaLoaded(info: info)),
    );
  }
}
