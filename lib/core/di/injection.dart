import "package:get_it/get_it.dart";
import "package:hive/hive.dart";
import "../../data/datasources/local/hive_datasource.dart";
import "../../data/datasources/remote/gpt_datasource.dart";
import "../../data/datasources/remote/dictionary_datasource.dart";
import "../../data/repositories/word_repository_impl.dart";
import "../../data/repositories/story_repository_impl.dart";
import "../../data/repositories/dictionary_repository_impl.dart";
import "../../data/repositories/history_repository_impl.dart";
import "../../domain/repositories/i_word_repository.dart";
import "../../domain/repositories/i_story_repository.dart";
import "../../domain/repositories/i_dictionary_repository.dart";
import "../../domain/repositories/i_history_repository.dart";
import "../constants/app_constants.dart";

final getIt = GetIt.instance;

void configureDependencies() {
  // Datasources
  getIt.registerLazySingleton<GptDatasource>(() => GptDatasource());
  getIt.registerLazySingleton<DictionaryDatasource>(
    () => DictionaryDatasource(),
  );
  getIt.registerLazySingleton<HiveDatasource>(
    () => HiveDatasource(
      wordsBox: Hive.box(AppConstants.wordsBoxName),
      historyBox: Hive.box(AppConstants.historyBoxName),
      dictionaryCacheBox: Hive.box(AppConstants.dictionaryCacheBoxName),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<IWordRepository>(
    () => WordRepositoryImpl(getIt<HiveDatasource>()),
  );
  getIt.registerLazySingleton<IStoryRepository>(
    () => StoryRepositoryImpl(getIt<GptDatasource>()),
  );
  getIt.registerLazySingleton<IDictionaryRepository>(
    () => DictionaryRepositoryImpl(
      getIt<DictionaryDatasource>(),
      getIt<HiveDatasource>(),
    ),
  );
  getIt.registerLazySingleton<IHistoryRepository>(
    () => HistoryRepositoryImpl(getIt<HiveDatasource>()),
  );
}
