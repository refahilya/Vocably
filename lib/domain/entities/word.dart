import "package:equatable/equatable.dart";

class Word extends Equatable {
  final String id;
  final String english;
  final String indonesian;
  final String partOfSpeech;
  final String topic;

  const Word({
    required this.id,
    required this.english,
    required this.indonesian,
    required this.partOfSpeech,
    required this.topic,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json["id"] as String,
        english: json["english"] as String,
        indonesian: json["indonesian"] as String,
        partOfSpeech: json["partOfSpeech"] as String,
        topic: json["topic"] as String,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "english": english,
        "indonesian": indonesian,
        "partOfSpeech": partOfSpeech,
        "topic": topic,
      };

  @override
  List<Object?> get props => [id, english, indonesian];
}
