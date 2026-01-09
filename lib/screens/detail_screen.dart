import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/material_model.dart';
import '../providers/material_provider.dart';

class DetailScreen extends StatefulWidget {
  final MaterialModel material;

  const DetailScreen({
    super.key,
    required this.material,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Materi'),
        actions: [
          IconButton(
            icon: Icon(
              widget.material.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Type
            Center(
              child: Column(
                children: [
                  Text(
                    widget.material.fileIcon,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.material.type.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              widget.material.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Info Cards
            _buildInfoCard(
              context,
              icon: Icons.subject,
              label: 'Mata Kuliah',
              value: widget.material.subject,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.person,
              label: 'Diunggah oleh',
              value: widget.material.uploadedBy,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              label: 'Tanggal Upload',
              value: widget.material.formattedUploadDate,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.download,
              label: 'Total Unduhan',
              value: '${widget.material.downloadCount}x',
            ),
            const SizedBox(height: 24),

            // Description
            if (widget.material.description.isNotEmpty) ...[
              Text(
                'Deskripsi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(widget.material.description),
              ),
              const SizedBox(height: 24),
            ],

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadMaterial,
                icon: _isDownloading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.download),
                label: Text(
                  _isDownloading ? 'Mengunduh...' : 'Unduh Materi',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    await provider.toggleFavorite(widget.material);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.material.isFavorite
                ? 'Dihapus dari favorit'
                : 'Ditambahkan ke favorit',
          ),
        ),
      );
    }
  }

  Future<void> _downloadMaterial() async {
    setState(() => _isDownloading = true);

    try {
      final provider = Provider.of<MaterialProvider>(context, listen: false);

      // Record download
      if (widget.material.id != null) {
        await provider.recordDownload(
          widget.material.id!,
          widget.material.title,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi berhasil diunduh!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
}