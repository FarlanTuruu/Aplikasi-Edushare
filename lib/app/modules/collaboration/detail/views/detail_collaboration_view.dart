import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/detail_collaboration_controller.dart';

class DetailCollaborationView extends GetView<DetailCollaborationController> {
  const DetailCollaborationView({super.key});

  static const Color _primaryPurple = Color(0xFF4A148C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Kolaborasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareCollab,
            tooltip: 'Bagikan',
          ),
        ],
      ),
      body: Obx(() {
        final data = controller.collab;
        final title = data['title']?.toString() ?? '';
        final mataKuliah = data['mataKuliah']?.toString() ?? '';
        final deskripsi = data['deskripsi']?.toString() ?? '';
        final date = data['date']?.toString() ?? '';
        final day = data['day']?.toString() ?? '';
        final createdAt = data['createdAt']?.toString() ?? '';
        final link = data['link']?.toString() ?? '';

        final displayDate = [day, date].where((e) => e.isNotEmpty).join(' ');
        final hasDate = displayDate.isNotEmpty || createdAt.isNotEmpty;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mata Kuliah
                    if (mataKuliah.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          mataKuliah,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date
                    if (hasDate)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.black54,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            createdAt.isNotEmpty ? createdAt : displayDate,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deskripsi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.description,
                                color: _primaryPurple,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            deskripsi.isEmpty
                                ? 'Tidak ada deskripsi.'
                                : deskripsi,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Link Dokumen
                    if (link.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.link,
                              color: _primaryPurple,
                            ),
                          ),
                          title: Text(
                            link,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: const Text('Buka tautan dokumen'),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            color: _primaryPurple,
                            onPressed: controller.openLink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
