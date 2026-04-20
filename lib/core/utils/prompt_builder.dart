import "../../domain/entities/word.dart";

class PromptBuilder {
  PromptBuilder._();

  // ── SYSTEM PROMPT ──
  static const String _systemPrompt = """
You are an English vocabulary teacher helping Indonesian students learn English.
Your stories should be:
- Simple and clear (A2-B1 level English)
- Exactly 5 sentences long
- Each target word must appear EXACTLY ONCE, used naturally
- Appropriate for junior high school-age Indonesian learners
- Never use complex vocabulary beyond the target words
Respond ONLY in the requested format. No explanations, no extra text.""";

  // ── GENERATE STORY WITH TRANSLATION ──
  static Map<String, dynamic> buildGenerateStoryRequest({
    required List<Word> words,
    required String title,
    required String model,
  }) {
    final wordList = words
        .map((w) => "${w.english} (${w.indonesian})")
        .join(", ");

    final userPrompt =
        """
Write a short story (exactly 5 sentences) about "$title" using ALL these words: $wordList.
Use each word exactly once. Keep sentences short and simple.

Respond in this exact format (no other text):
ENGLISH:
[sentence 1]
[sentence 2]
[sentence 3]
[sentence 4]
[sentence 5]

INDONESIAN:
[terjemahan kalimat 1]
[terjemahan kalimat 2]
[terjemahan kalimat 3]
[terjemahan kalimat 4]
[terjemahan kalimat 5]""";

    final request = {
      "model": model,
      "messages": [
        {"role": "system", "content": _systemPrompt},
        {"role": "user", "content": userPrompt},
      ],
    };

    if (model.startsWith("gpt-5")) {
      request["temperature"] = 1;
      request["max_completion_tokens"] = 1200;
    } else {
      request["temperature"] = 1;
      request["max_tokens"] = 800;
    }

    return request;
  }

  // ── CO-WRITE INFILL ──
  static Map<String, dynamic> buildInfillRequest({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
    required String model,
  }) {
    final storyContext = previousSentences.join(" ");
    final remaining = unusedWords
        .map((w) => "${w.english} (${w.indonesian})")
        .join(", ");

    final userPrompt =
        """
We are co-writing a story titled "$storyTitle".
Story so far: "$storyContext"

Remaining words to use: $remaining

Write the NEXT SINGLE SENTENCE that:
1. Continues the story naturally
2. Uses AT LEAST ONE word from the remaining list
3. Is short and clear (max 15 words)

Respond with ONLY the sentence, nothing else.""";

    final request = {
      "model": model,
      "messages": [
        {"role": "system", "content": _systemPrompt},
        {"role": "user", "content": userPrompt},
      ],
    };

    if (model.startsWith("gpt-5")) {
      request["temperature"] = 1;
      request["max_completion_tokens"] = 120;
    } else {
      request["temperature"] = 0.8;
      request["max_tokens"] = 100;
    }

    return request;
  }

  // ── VALIDATE USER SENTENCE ──
  static Map<String, dynamic> buildValidateSentenceRequest({
    required String userSentence,
    required List<Word> targetWords,
    required List<String> previousSentences,
    required String model,
  }) {
    final wordList = targetWords.map((w) => w.english).join(", ");
    final context = previousSentences.isNotEmpty
        ? "Story so far: ${previousSentences.join(' ')}"
        : "This is the first sentence.";

    final userPrompt =
        """
A student wrote this sentence: "$userSentence"
$context
Target words: $wordList

Check:
1. Which target word(s) does the sentence use? (case-insensitive match)
2. Is the grammar correct?
3. Does it make sense in context?

Respond in this exact format:
WORDS_USED: [comma-separated list of target words used, or NONE]
GRAMMAR_OK: [YES or NO]
FEEDBACK: [1 short sentence in Indonesian about the quality]""";

    final request = {
      "model": model,
      "messages": [
        {"role": "user", "content": userPrompt},
      ],
    };

    if (model.startsWith("gpt-5")) {
      request["temperature"] = 1;
      request["max_completion_tokens"] = 200;
    } else {
      request["temperature"] = 1;
      request["max_tokens"] = 200;
    }

    return request;
  }

  // ── HINT REQUEST ──
  static Map<String, dynamic> buildHintRequest({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
    required String model,
  }) {
    final context = previousSentences.isNotEmpty
        ? previousSentences.join(" ")
        : "(belum ada kalimat)";
    final remaining = unusedWords
        .map((w) => "${w.english} (${w.indonesian})")
        .join(", ");

    final userPrompt =
        """
Help a student continue a story titled "$storyTitle".
Story so far: "$context"
Remaining words to use: $remaining

Give ONE simple example sentence (max 12 words) using one of the remaining words.
Respond with ONLY the sentence.""";

    final request = {
      "model": model,
      "messages": [
        {"role": "system", "content": _systemPrompt},
        {"role": "user", "content": userPrompt},
      ],
    };

    if (model.startsWith("gpt-5")) {
      request["temperature"] = 1;
      request["max_completion_tokens"] = 80;
    } else {
      request["temperature"] = 1;
      request["max_tokens"] = 60;
    }

    return request;
  }
}
