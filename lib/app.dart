import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "core/di/injection.dart";
import "core/theme/app_theme.dart";
import "domain/repositories/i_word_repository.dart";
import "domain/repositories/i_dictionary_repository.dart";
import "features/word_selection/bloc/word_selection_bloc.dart";
import "features/word_selection/bloc/word_selection_event.dart";
import "features/word_selection/screens/word_selection_screen.dart";
import "features/history/screens/history_screen.dart";
import "features/settings/screens/settings_screen.dart";

class VocablyApp extends StatelessWidget {
  const VocablyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Vocably3",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _MainShell(),
      routes: {
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Word Selection (Home)
          BlocProvider(
            create: (_) => WordSelectionBloc(
              getIt<IWordRepository>(),
              getIt<IDictionaryRepository>(),
            )..add(const LoadWords()),
            child: const WordSelectionScreen(),
          ),
          // Tab 1: History
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: "Belajar",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: "Riwayat",
          ),
        ],
      ),
    );
  }
}
