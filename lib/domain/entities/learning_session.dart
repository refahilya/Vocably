import "package:equatable/equatable.dart";
import "word.dart";

class LearningSession extends Equatable {
  final String id;
  final List<Word> targetWords;
  final DateTime startedAt;
  final DateTime? completedAt;

  const LearningSession({
    required this.id,
    required this.targetWords,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [id];
}
