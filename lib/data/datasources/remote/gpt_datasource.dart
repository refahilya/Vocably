import "package:dio/dio.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter/foundation.dart";
import "../../../domain/entities/word.dart";
import "../../../core/network/dio_client.dart";
import "../../../core/utils/prompt_builder.dart";

class GptDatasource {
  final Dio _dio;
  final String _model;

  GptDatasource()
    : _dio = DioClient.instance,
      _model = dotenv.env["OPENAI_MODEL"] ?? "gpt-4o-mini";

  Future<String> _callApi(Map<String, dynamic> requestBody) async {
    final apiPath = dotenv.env["OPENAI_API_PATH"] ?? "/chat/completions";
    try {
      final response = await _dio.post(apiPath, data: requestBody);
      final data = response.data;
      final content = _extractContentFromResponse(data);

      if (content == null || content.trim().isEmpty) {
        debugPrint(
          "[GptDatasource] Response did not contain assistant text: $data",
        );
        throw Exception(
          "API mengembalikan response kosong. Periksa konfigurasi API.",
        );
      }

      return content.trim();
    } on DioException catch (e) {
      debugPrint("[GptDatasource] Error - Status: ${e.response?.statusCode}");
      debugPrint("[GptDatasource] Response: ${e.response?.data}");
      final responsePayload = e.response?.data != null
          ? " - ${e.response?.data}"
          : "";
      if (e.response?.statusCode == 401) {
        throw Exception(
          "API key tidak valid. Cek pengaturan API.$responsePayload",
        );
      } else if (e.response?.statusCode == 429) {
        throw Exception(
          "Rate limit tercapai. Tunggu beberapa detik.$responsePayload",
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          "Koneksi timeout. Periksa koneksi internet.$responsePayload",
        );
      }
      throw Exception("API Error: ${e.message}$responsePayload");
    }
  }

  String? _extractContentFromResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final choices = data["choices"];
      if (choices is List) {
        for (final choice in choices) {
          final content = _extractTextFromChoice(choice);
          if (content != null && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      }
      return _extractText(data["content"]) ?? _extractText(data["output_text"]);
    }
    return null;
  }

  String? _extractTextFromChoice(dynamic choice) {
    if (choice is Map<String, dynamic>) {
      final message = choice["message"];
      final textFromMessage = _extractText(message);
      if (textFromMessage != null && textFromMessage.trim().isNotEmpty) {
        return textFromMessage;
      }
      final directContent = _extractText(choice["content"]);
      if (directContent != null && directContent.trim().isNotEmpty) {
        return directContent;
      }
      return _extractText(choice["output_text"]);
    }
    return null;
  }

  String? _extractText(dynamic value) {
    if (value is String) {
      if (value.trim().isEmpty) return null;
      return value;
    }
    if (value is Map<String, dynamic>) {
      final keys = ["content", "text", "body", "output_text", "raw"];
      for (final key in keys) {
        if (value.containsKey(key)) {
          final extracted = _extractText(value[key]);
          if (extracted != null && extracted.trim().isNotEmpty) {
            return extracted;
          }
        }
      }
      for (final nested in value.values) {
        final extracted = _extractText(nested);
        if (extracted != null && extracted.trim().isNotEmpty) {
          return extracted;
        }
      }
    }
    if (value is Iterable) {
      final pieces = value
          .map(_extractText)
          .where((e) => e != null && e.trim().isNotEmpty)
          .cast<String>()
          .toList();
      if (pieces.isNotEmpty) return pieces.join(" ");
    }
    return null;
  }

  Future<String> generateStory({
    required List<Word> words,
    required String title,
  }) async {
    final body = PromptBuilder.buildGenerateStoryRequest(
      words: words,
      title: title,
      model: _model,
    );
    return _callApi(body);
  }

  Future<String> infillNextSentence({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
  }) async {
    final body = PromptBuilder.buildInfillRequest(
      previousSentences: previousSentences,
      unusedWords: unusedWords,
      storyTitle: storyTitle,
      model: _model,
    );
    return _callApi(body);
  }

  Future<String> validateSentence({
    required String userSentence,
    required List<Word> targetWords,
    required List<String> previousSentences,
  }) async {
    final body = PromptBuilder.buildValidateSentenceRequest(
      userSentence: userSentence,
      targetWords: targetWords,
      previousSentences: previousSentences,
      model: _model,
    );
    return _callApi(body);
  }

  Future<String> getHint({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
  }) async {
    final body = PromptBuilder.buildHintRequest(
      previousSentences: previousSentences,
      unusedWords: unusedWords,
      storyTitle: storyTitle,
      model: _model,
    );
    return _callApi(body);
  }
}
