import 'package:equatable/equatable.dart';

class WelcomeMessage extends Equatable {
  const WelcomeMessage({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];
}
