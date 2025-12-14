// File: /lib/app/modules/notes/detail/views/detail_notes_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_notes_controller.dart';

class DetailNotesView extends GetView<DetailNotesController> {
  const DetailNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B2C91),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Catatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareNote,
            tooltip: 'Bagikan',
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  controller.editNote();
                  break;
                case 'archive':
                  controller.toggleArchive();
                  break;
                case 'delete':
                  controller.deleteNote();
                  break;
              }
            },
            itemBuilder: (context) {
              final isFromArchive = controller.isFromArchive.value;
              final isFromScheduled = controller.isFromScheduled.value;
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 12),
                      Text('Edit Catatan'),
                    ],
                  ),
                ),
                // 🔧 Dynamic menu item based on source
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        isFromArchive
                            ? Icons.unarchive
                            : isFromScheduled
                            ? Icons.publish
                            : Icons.archive,
                        color: isFromArchive
                            ? Colors.green
                            : isFromScheduled
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isFromArchive
                            ? 'Kembalikan'
                            : isFromScheduled
                            ? 'Publikasikan'
                            : 'Arsipkan',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Hapus'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final note = controller.note.value;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B2C91), Color(0xFF8E44AD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mata Kuliah Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        note.mataKuliah,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          note.fullDate,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Color(0xFF6B2C91),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B2C91),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            note.description,
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

                    // File Attachment (if exists)
                    if (note.fileName != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
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
                              color: const Color(
                                0xFF6B2C91,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.attach_file,
                              color: Color(0xFF6B2C91),
                            ),
                          ),
                          title: Text(
                            note.fileName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'File terlampir',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            color: const Color(0xFF6B2C91),
                            onPressed: controller.downloadFile,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 🔧 Dynamic Action Buttons based on source
                    Obx(() {
                      final isFromArchive = controller.isFromArchive.value;
                      final isFromScheduled = controller.isFromScheduled.value;

                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.editNote,
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6B2C91),
                                side: const BorderSide(
                                  color: Color(0xFF6B2C91),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controller.toggleArchive,
                              icon: Icon(
                                isFromArchive
                                    ? Icons.unarchive
                                    : isFromScheduled
                                    ? Icons.publish
                                    : Icons.archive,
                                size: 20,
                              ),
                              label: Text(
                                isFromArchive
                                    ? 'Kembalikan'
                                    : isFromScheduled
                                    ? 'Publikasikan'
                                    : 'Arsipkan',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFromArchive
                                    ? Colors.green
                                    : isFromScheduled
                                    ? Colors.green
                                    : Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 12),

                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.deleteNote,
                        icon: const Icon(Icons.delete, size: 20),
                        label: const Text('Hapus Catatan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
