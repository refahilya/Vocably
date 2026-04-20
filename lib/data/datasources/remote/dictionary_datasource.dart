import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "../../../core/constants/app_constants.dart";
import "../../../core/network/dio_client.dart";
import "../../../domain/entities/dictionary_entry.dart";

class DictionaryDatasource {
  final Dio _dio;

  DictionaryDatasource() : _dio = DioClient.dictionaryInstance;

  /// Look up a word using the Free Dictionary API.
  /// Returns a [DictionaryEntry] or throws if not found.
  Future<DictionaryEntry> lookupWord(String word) async {
    final url = "${AppConstants.dictionaryBaseUrl}/$word";
    try {
      final response = await _dio.get(url);
      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return DictionaryEntry.fromApiResponse(
          data[0] as Map<String, dynamic>,
        );
      }

      throw Exception("Kata '$word' tidak ditemukan di kamus.");
    } on DioException catch (e) {
      debugPrint("[DictionaryDatasource] Error looking up '$word': ${e.message}");
      if (e.response?.statusCode == 404) {
        throw Exception("Kata '$word' tidak ditemukan di kamus.");
      }
      throw Exception("Gagal mengambil definisi: ${e.message}");
    }
  }
}
