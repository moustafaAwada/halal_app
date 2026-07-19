import '../../domain/entities/welcome_message.dart';

class WelcomeMessageModel extends WelcomeMessage {
  const WelcomeMessageModel({required super.text});

  factory WelcomeMessageModel.fromJson(Map<String, dynamic> json) {
    return WelcomeMessageModel(text: json['text'] as String);
  }

  Map<String, dynamic> toJson() => {'text': text};

  WelcomeMessage toEntity() => WelcomeMessage(text: text);
}
