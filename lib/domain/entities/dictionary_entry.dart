import "package:equatable/equatable.dart";

class DictionaryEntry extends Equatable {
  final String word;
  final String phonetic;
  final String? audioUrl;
  final List<DictionaryMeaning> meanings;

  const DictionaryEntry({
    required this.word,
    required this.phonetic,
    this.audioUrl,
    required this.meanings,
  });

  factory DictionaryEntry.fromApiResponse(Map<String, dynamic> json) {
    final phonetics = json["phonetics"] as List<dynamic>? ?? [];
    String phonetic = json["phonetic"] as String? ?? "";
    String? audioUrl;

    for (final p in phonetics) {
      if (p is Map<String, dynamic>) {
        if (phonetic.isEmpty && p["text"] != null) {
          phonetic = p["text"] as String;
        }
        final audio = p["audio"] as String?;
        if (audio != null && audio.isNotEmpty) {
          audioUrl = audio;
        }
      }
    }

    final meaningsRaw = json["meanings"] as List<dynamic>? ?? [];
    final meanings = meaningsRaw.map((m) {
      final defs = (m["definitions"] as List<dynamic>? ?? []).map((d) {
        return DictionaryDefinition(
          definition: d["definition"] as String? ?? "",
          example: d["example"] as String?,
        );
      }).toList();

      return DictionaryMeaning(
        partOfSpeech: m["partOfSpeech"] as String? ?? "",
        definitions: defs,
      );
    }).toList();

    return DictionaryEntry(
      word: json["word"] as String? ?? "",
      phonetic: phonetic,
      audioUrl: audioUrl,
      meanings: meanings,
    );
  }

  @override
  List<Object?> get props => [word];
}

class DictionaryMeaning extends Equatable {
  final String partOfSpeech;
  final List<DictionaryDefinition> definitions;

  const DictionaryMeaning({
    required this.partOfSpeech,
    required this.definitions,
  });

  @override
  List<Object?> get props => [partOfSpeech, definitions];
}

class DictionaryDefinition extends Equatable {
  final String definition;
  final String? example;

  const DictionaryDefinition({
    required this.definition,
    this.example,
  });

  @override
  List<Object?> get props => [definition, example];
}
