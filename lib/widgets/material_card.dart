import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../models/material_model.dart';
import '../providers/material_provider.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback? onTap;

  const MaterialCard({
    super.key,
    required this.material,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _openFile(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Title, Favorite
              Row(
                children: [
                  // File Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getSubjectColor(material.subject).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        material.fileIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title & Subject
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSubjectColor(material.subject),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            material.subject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Favorite Button
                  IconButton(
                    icon: Icon(
                      material.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: material.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(context),
                  ),
                ],
              ),

              // Description
              if (material.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  material.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Footer: Uploader, Date, Download Count
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    material.uploadedBy,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    material.formattedUploadDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.download, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${material.downloadCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Buka Button
                  _ActionButton(
                    icon: Icons.folder_open,
                    label: 'Buka',
                    color: Colors.blue,
                    onPressed: () => _openFile(context),
                  ),

                  // Download Button
                  _ActionButton(
                    icon: Icons.download,
                    label: 'Download',
                    color: Colors.green,
                    onPressed: () => _downloadFile(context),
                  ),

                  // Share Button
                  _ActionButton(
                    icon: Icons.share,
                    label: 'Bagikan',
                    color: Colors.purple,
                    onPressed: () => _shareFile(context),
                  ),

                  // Delete Button
                  _ActionButton(
                    icon: Icons.delete,
                    label: 'Hapus',
                    color: Colors.red,
                    onPressed: () => _deleteFile(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // ACTION METHODS
  // ========================================================================

  /// Open file with default app
  Future<void> _openFile(BuildContext context) async {
    try {
      final file = File(material.filePath);

      if (!await file.exists()) {
        if (context.mounted) {
          _showSnackBar(
            context,
            '❌ File tidak ditemukan: ${material.title}',
            Colors.red,
          );
        }
        return;
      }

      final result = await OpenFilex.open(material.filePath);

      if (result.type != ResultType.done && context.mounted) {
        _showSnackBar(
          context,
          '⚠️ Tidak ada aplikasi untuk membuka file ini',
          Colors.orange,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '❌ Error membuka file: $e',
          Colors.red,
        );
      }
    }
  }

  /// Download file (increment counter & record to database)
  Future<void> _downloadFile(BuildContext context) async {
    try {
      _showSnackBar(
        context,
        '⬇️ Mengunduh ${material.title}...',
        Colors.blue,
      );

      final provider = Provider.of<MaterialProvider>(context, listen: false);

      // Record download (increment counter + save to downloads table)
      if (material.id != null) {
        await provider.recordDownload(material.id!, material.title);
      }

      if (context.mounted) {
        _showSnackBar(
          context,
          '✅ ${material.title} berhasil diunduh!',
          Colors.green,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '❌ Gagal mengunduh: $e',
          Colors.red,
        );
      }
    }
  }

  /// Share file via Share Plus
  Future<void> _shareFile(BuildContext context) async {
    try {
      final file = File(material.filePath);

      if (await file.exists()) {
        // Share file
        await Share.shareXFiles(
          [XFile(material.filePath)],
          text: '${material.title}\n${material.description}',
          subject: material.title,
        );

        if (context.mounted) {
          _showSnackBar(
            context,
            '📤 Membagikan ${material.title}',
            Colors.blue,
          );
        }
      } else {
        // File doesn't exist, share text only
        await Share.share(
          '${material.title}\n\n${material.description}\n\nSubjek: ${material.subject}\nDiunggah oleh: ${material.uploadedBy}',
          subject: material.title,
        );

        if (context.mounted) {
          _showSnackBar(
            context,
            '📤 Membagikan info ${material.title}',
            Colors.blue,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '❌ Gagal membagikan: $e',
          Colors.red,
        );
      }
    }
  }

  /// Delete material with confirmation
  Future<void> _deleteFile(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus materi ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subjek: ${material.subject}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Tindakan ini tidak dapat dibatalkan!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = Provider.of<MaterialProvider>(context, listen: false);

        if (material.id != null) {
          final success = await provider.deleteMaterial(material.id!);

          if (success && context.mounted) {
            _showSnackBar(
              context,
              '✅ ${material.title} berhasil dihapus',
              Colors.green,
            );
          } else if (context.mounted) {
            _showSnackBar(
              context,
              '❌ Gagal menghapus materi',
              Colors.red,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(
            context,
            '❌ Error: $e',
            Colors.red,
          );
        }
      }
    }
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      final provider = Provider.of<MaterialProvider>(context, listen: false);
      await provider.toggleFavorite(material);

      if (context.mounted) {
        final message = material.isFavorite
            ? '💔 Dihapus dari favorit'
            : '❤️ Ditambahkan ke favorit';
        _showSnackBar(context, message, Colors.pink);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '❌ Gagal mengubah favorit: $e',
          Colors.red,
        );
      }
    }
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Show snackbar message
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Get color based on subject
  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematika':
        return Colors.blue;
      case 'fisika':
        return Colors.orange;
      case 'kimia':
        return Colors.green;
      case 'biologi':
        return Colors.teal;
      case 'bahasa indonesia':
        return Colors.red;
      case 'bahasa inggris':
        return Colors.purple;
      case 'sejarah':
        return Colors.brown;
      case 'geografi':
        return Colors.cyan;
      case 'ekonomi':
        return Colors.amber;
      case 'sosiologi':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

// ==========================================================================
// ACTION BUTTON WIDGET
// ==========================================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}