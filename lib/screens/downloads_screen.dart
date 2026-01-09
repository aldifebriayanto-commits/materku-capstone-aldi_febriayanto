import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../providers/material_provider.dart';
import '../models/material_model.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MaterialProvider>().loadDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
        elevation: 0,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          // Clear All Button
          Consumer<MaterialProvider>(
            builder: (context, provider, _) {
              final downloads = provider.materials
                  .where((m) => m.downloadCount > 0)
                  .toList();

              if (downloads.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Hapus Semua',
                onPressed: () => _clearAllDownloads(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, _) {
          // Filter materials that have been downloaded (downloadCount > 0)
          final downloads = provider.materials
              .where((m) => m.downloadCount > 0)
              .toList();

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada download',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download materi untuk melihatnya di sini',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final material = downloads[index];
              return _DownloadCard(
                material: material,
                onOpen: () => _openFile(context, material),
                onDelete: () => _deleteDownload(context, material),
                onShare: () => _shareFile(context, material),
              );
            },
          );
        },
      ),
    );
  }

  // ========================================================================
  // ACTION METHODS
  // ========================================================================

  /// Open file with default app
  Future<void> _openFile(BuildContext context, MaterialModel material) async {
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

  /// Share file
  Future<void> _shareFile(BuildContext context, MaterialModel material) async {
    try {
      final file = File(material.filePath);

      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(material.filePath)],
          text: '${material.title}\n${material.description}',
          subject: material.title,
        );
      } else {
        await Share.share(
          '${material.title}\n\n${material.description}\n\nSubjek: ${material.subject}',
          subject: material.title,
        );
      }

      if (context.mounted) {
        _showSnackBar(
          context,
          '📤 Membagikan ${material.title}',
          Colors.blue,
        );
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

  /// Delete single download
  Future<void> _deleteDownload(BuildContext context, MaterialModel material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hapus materi ini dari daftar download?'),
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
                    'Downloaded: ${material.downloadCount}x',
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
              'Catatan: File tidak akan dihapus, hanya dari daftar ini.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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

        // Reset download count to 0
        if (material.id != null) {
          final updatedMaterial = material.copyWith(downloadCount: 0);
          await provider.updateMaterial(material.id!, updatedMaterial);

          if (context.mounted) {
            _showSnackBar(
              context,
              '✅ ${material.title} dihapus dari download',
              Colors.green,
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

  /// Clear all downloads
  Future<void> _clearAllDownloads(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Download'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hapus semua materi dari daftar download?'),
            SizedBox(height: 12),
            Text(
              '⚠️ Catatan: File tidak akan dihapus, hanya daftar download yang direset.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
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
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = Provider.of<MaterialProvider>(context, listen: false);

        // Reset download count for all materials
        final downloads = provider.materials
            .where((m) => m.downloadCount > 0)
            .toList();

        for (var material in downloads) {
          if (material.id != null) {
            final updatedMaterial = material.copyWith(downloadCount: 0);
            await provider.updateMaterial(material.id!, updatedMaterial);
          }
        }

        if (context.mounted) {
          _showSnackBar(
            context,
            '✅ Semua download berhasil dihapus',
            Colors.green,
          );
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

  /// Show snackbar
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
}

// ==========================================================================
// DOWNLOAD CARD WIDGET
// ==========================================================================

class _DownloadCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _DownloadCard({
    required this.material,
    required this.onOpen,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(material.id ?? material.title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Download'),
            content: Text('Hapus "${material.title}" dari daftar download?'),
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
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpen,
            onLongPress: () => _showOptionsMenu(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade300, Colors.teal.shade300],
                      ),
                    ),
                    child: const Icon(
                      Icons.download_done,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          material.subject,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Downloaded: ${material.downloadCount}x',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Open Button
                      IconButton(
                        icon: const Icon(Icons.folder_open),
                        color: Colors.blue,
                        tooltip: 'Buka',
                        onPressed: onOpen,
                      ),

                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'Hapus',
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show options bottom sheet
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  material.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 32),

              // Options
              _OptionTile(
                icon: Icons.folder_open,
                title: 'Buka File',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  onOpen();
                },
              ),
              _OptionTile(
                icon: Icons.share,
                title: 'Bagikan',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
              _OptionTile(
                icon: Icons.delete,
                title: 'Hapus dari Download',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// OPTION TILE WIDGET
// ==========================================================================

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }
}