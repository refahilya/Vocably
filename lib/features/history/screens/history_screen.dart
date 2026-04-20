import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:gap/gap.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/di/injection.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/repositories/i_history_repository.dart";

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final repo = getIt<IHistoryRepository>();
      final data = await repo.getHistory();
      if (mounted) {
        setState(() {
          _history = data.reversed.toList(); // newest first
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Belajar")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                      const Gap(16),
                      Text(
                        "Belum ada riwayat belajar",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "Selesaikan satu sesi belajar untuk melihat riwayat",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _history.length,
                    itemBuilder: (context, index) => _HistoryCard(
                      data: _history[index],
                      index: index,
                    ),
                  ),
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;

  const _HistoryCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(data["date"] as String? ?? "");
    final wordsRaw = data["words"] as List<dynamic>? ?? [];
    final words = wordsRaw.map((w) {
      final map = Map<String, dynamic>.from(w as Map);
      return Word.fromJson(map);
    }).toList();

    final dateStr = date != null
        ? "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
        : "Tanggal tidak tersedia";

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: AppTheme.textSecondary),
                const Gap(6),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${words.length} kata",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            // Word chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: words.map((word) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.wordBubble,
                    borderRadius: AppTheme.chipRadius,
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: word.english,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: " • ${word.indonesian}",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (80 * index).ms, duration: 300.ms)
        .slideX(begin: 0.03);
  }
}
