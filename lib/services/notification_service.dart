import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Service untuk mengelola notifications (Simplified Version)
///
/// Fitur:
/// - In-app notifications (SnackBar/Dialog)
/// - Console logging untuk development
/// - Cross-platform compatible
/// - NO external notification package dependencies
///
/// NOTE: Untuk production, consider using:
/// - flutter_local_notifications (jika bug sudah fix)
/// - awesome_notifications
/// - local_notifier
class NotificationService {
  // ===========================================================================
  // SINGLETON
  // ===========================================================================

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ===========================================================================
  // PROPERTIES
  // ===========================================================================

  bool _isInitialized = false;
  final List<_NotificationItem> _notifications = [];

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = true;
      debugPrint('✅ NotificationService initialized (Simplified Mode)');
      return true;
    } catch (e) {
      debugPrint('❌ NotificationService init error: $e');
      return false;
    }
  }

  // ===========================================================================
  // BASIC NOTIFICATION (IN-APP)
  // ===========================================================================

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Duration duration = const Duration(seconds: 4),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Store notification
    final notification = _NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: payload,
      timestamp: DateTime.now(),
    );

    _notifications.add(notification);

    // Log to console
    debugPrint('📢 NOTIFICATION: $title - $body');

    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeAt(0);
    }
  }

  // ===========================================================================
  // SHOW IN-APP SNACKBAR (REQUIRES BuildContext)
  // ===========================================================================

  void showSnackBar(
      BuildContext context, {
        required String title,
        required String message,
        Duration duration = const Duration(seconds: 3),
        bool isError = false,
      }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ===========================================================================
  // SPECIFIC NOTIFICATIONS
  // ===========================================================================

  Future<void> showUploadSuccess({
    required String title,
    String? materialId,
  }) async {
    await showNotification(
      title: '✅ Upload Berhasil',
      body: 'Materi "$title" berhasil diupload',
      payload: materialId != null ? 'view_material:$materialId' : 'view_uploads',
    );
  }

  Future<void> showUploadFailed({
    required String title,
    String? error,
  }) async {
    await showNotification(
      title: '❌ Upload Gagal',
      body: error ?? 'Upload "$title" gagal',
    );
  }

  Future<void> showDownloadComplete({
    required String title,
    String? materialId,
  }) async {
    await showNotification(
      title: '📥 Download Selesai',
      body: 'Materi "$title" siap dibuka',
      payload: materialId != null ? 'view_material:$materialId' : 'view_downloads',
    );
  }

  // ===========================================================================
  // PROGRESS NOTIFICATION (CONSOLE LOG ONLY)
  // ===========================================================================

  Future<void> showProgress({
    required int id,
    required String title,
    required double progress,
  }) async {
    if (!_isInitialized) await initialize();

    final percent = (progress * 100).clamp(0, 100).toInt();

    debugPrint('📊 PROGRESS [$id]: $title - $percent%');
  }

  // ===========================================================================
  // MANAGEMENT
  // ===========================================================================

  Future<void> cancel(int id) async {
    _notifications.removeWhere((n) => n.id == id);
    debugPrint('🗑️ Notification cancelled: $id');
  }

  Future<void> cancelAll() async {
    _notifications.clear();
    debugPrint('🗑️ All notifications cancelled');
  }

  Future<List<_NotificationItem>> getActiveNotifications() async {
    return List.from(_notifications);
  }

  // ===========================================================================
  // NOTIFICATION HISTORY
  // ===========================================================================

  List<_NotificationItem> getNotificationHistory({int limit = 20}) {
    final sorted = List<_NotificationItem>.from(_notifications)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return sorted.take(limit).toList();
  }

  void clearHistory() {
    _notifications.clear();
  }
}

// ===========================================================================
// NOTIFICATION ITEM MODEL
// ===========================================================================

class _NotificationItem {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[$timestamp] $title: $body';
  }
}