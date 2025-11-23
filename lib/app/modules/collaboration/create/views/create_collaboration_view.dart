import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_collaboration_controller.dart';

class CreateCollaborationView extends GetView<CreateCollaborationController> {
  const CreateCollaborationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Purple background
          Container(color: const Color(0xFF7C3AED)),
          // Main content with scroll
          SingleChildScrollView(
            child: Column(
              children: [
                // Header section with wave
                Stack(
                  children: [
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6B46C1), Color(0xFF7C3AED)],
                        ),
                      ),
                    ),
                    // Curved wave
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: ClipPath(
                        clipper: WaveClipper(),
                        child: Container(height: 180, color: Colors.white),
                      ),
                    ),
                    // Header content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Catatan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF6B46C1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.settings,
                                  color: Color(0xFF6B46C1),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Main content area
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // List button
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF6B46C1),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'List',
                              style: TextStyle(
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Collaboration header card
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9D5FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFDDD6FE),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF6B46C1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nanda Adela',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Online',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bagikan Catatan Kolaborasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Input fields
                      _buildInputField(
                        label: 'Mata Kuliah',
                        hint: 'Enter input',
                        controller: controller.mataKuliahController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Judul Catatan',
                        hint: 'Enter input',
                        controller: controller.judulCatatanController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Deskripsi',
                        hint: 'Enter input',
                        controller: controller.deskripsiController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Link Docs',
                        hint: 'Enter input',
                        controller: controller.linkDocsController,
                      ),
                      const SizedBox(height: 28),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF6B46C1),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => controller.uploadFile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home_outlined),
            _buildBottomNavItem(Icons.sentiment_satisfied_outlined),
            _buildBottomNavItem(Icons.add_circle_outline, isActive: true),
            _buildBottomNavItem(Icons.mic_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B46C1),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem(IconData icon, {bool isActive = false}) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFF6B46C1),
              shape: BoxShape.circle,
            )
          : null,
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey[400],
        size: isActive ? 28 : 24,
      ),
    );
  }
}

// Wave clipper for curved design
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.3);

    final firstCurve = Offset(size.width * 0.25, size.height * 0.7);
    final secondCurve = Offset(size.width * 0.75, size.height * 0.2);
    final endPoint = Offset(size.width, size.height * 0.4);

    path.quadraticBezierTo(
      firstCurve.dx,
      firstCurve.dy,
      secondCurve.dx,
      secondCurve.dy,
    );

    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.1,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
