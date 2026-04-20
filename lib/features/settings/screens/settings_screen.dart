import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:gap/gap.dart";
import "../../../core/theme/app_theme.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.cardRadius,
            ),
            child: Column(
              children: [
                const Icon(Icons.school, size: 48, color: Colors.white),
                const Gap(12),
                const Text(
                  "Vocably3",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  "Media Pembelajaran Kosakata Bahasa Inggris",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(4),
                Text(
                  "v1.0.0",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),
          const Gap(20),

          // Settings items
          _SettingsTile(
            icon: Icons.info_outline,
            title: "Tentang Aplikasi",
            subtitle: "Informasi tentang Vocably3",
            onTap: () => _showAboutDialog(context),
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: "Hapus Riwayat",
            subtitle: "Menghapus semua data riwayat belajar",
            onTap: () => _showClearHistoryDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Tentang Vocably3"),
        content: const Text(
          "Vocably3 adalah media pembelajaran kosakata Bahasa Inggris "
          "untuk siswa dengan bahasa native Indonesia.\n\n"
          "Menggunakan teknologi AI untuk menghasilkan cerita interaktif "
          "dan latihan berbasis konteks.\n\n"
          "Dibuat sebagai bagian dari penelitian skripsi.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Riwayat?"),
        content: const Text(
          "Semua data riwayat kata yang sudah dipelajari akan dihapus. "
          "Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Riwayat berhasil dihapus")),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.error.withValues(alpha: 0.1)
                : AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppTheme.error : AppTheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
