import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/usecases/get_home_data.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required GetHomeDataUseCase getHomeDataUseCase})
      : _getHomeDataUseCase = getHomeDataUseCase,
        super(const HomeInitial());

  final GetHomeDataUseCase _getHomeDataUseCase;

  Future<void> loadHomeData() async {
    emit(const HomeLoading());

    final result = await _getHomeDataUseCase(const NoParams());

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (data) => emit(HomeLoaded(data: data)),
    );
  }

  Future<void> retry() => loadHomeData();
}
