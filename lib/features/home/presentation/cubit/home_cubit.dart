import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_welcome_message.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.getWelcomeMessage}) : super(const HomeInitial());

  final GetWelcomeMessage getWelcomeMessage;

  Future<void> loadWelcomeMessage() async {
    emit(const HomeLoading());

    final result = await getWelcomeMessage(const NoParams());

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (welcomeMessage) => emit(HomeLoaded(message: welcomeMessage.text)),
    );
  }
}
