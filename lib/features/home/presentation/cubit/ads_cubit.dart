import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/ad.dart';
import '../../domain/usecases/get_available_ads.dart';

part 'ads_state.dart';

class AdsCubit extends Cubit<AdsState> {
  AdsCubit({required GetAvailableAdsUseCase getAvailableAdsUseCase})
      : _getAvailableAdsUseCase = getAvailableAdsUseCase,
        super(const AdsInitial());

  final GetAvailableAdsUseCase _getAvailableAdsUseCase;

  Future<void> loadAds() async {
    emit(const AdsLoading());

    final result = await _getAvailableAdsUseCase(const NoParams());

    result.fold(
      (failure) => emit(AdsError(message: failure.message)),
      (ads) => emit(AdsLoaded(ads: ads)),
    );
  }

  Future<void> retry() => loadAds();
}
