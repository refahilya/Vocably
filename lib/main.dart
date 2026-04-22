import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hive_flutter/hive_flutter.dart";
import "core/constants/app_constants.dart";
import "core/di/injection.dart";
import "data/datasources/local/hive_datasource.dart";
import "app.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  print("API KEY: ${dotenv.env['OPENAI_API_KEY']}");

  // Init Hive local database
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.wordsBoxName);
  await Hive.openBox(AppConstants.historyBoxName);
  await Hive.openBox(AppConstants.dictionaryCacheBoxName);

  // Setup dependency injection
  configureDependencies();

  // Load words from JSON into Hive on first run
  final hiveDatasource = getIt<HiveDatasource>();
  await hiveDatasource.initializeWords();

  runApp(const VocablyApp());
}
