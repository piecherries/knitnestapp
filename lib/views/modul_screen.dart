import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'materi_detail_screen.dart';
import 'module_detail_screen.dart';

class ModulScreen extends StatelessWidget {
  const ModulScreen({super.key});

  static const darkBg = Color(0xFF140F1F);
  static const darkPurple = Color(0xFF2B164A);
  static const funkyPink = Color(0xFFFF8FAB);
  static const softPink = Color(0xFFFFB7D5);
  static const softLilac = Color(0xFFD8C4FF);
  static const cream = Color(0xFFFFF8F2);
  static const mint = Color(0xFF65B891);
  static const gold = Color(0xFFFFB703);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF140F1F),
              Color(0xFF2B164A),
              Color(0xFF4A1D4F),
              Color(0xFF1A1533),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: softPink),
                );
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>? ?? {};

              final unlockedList = userData['unlockedModuls'] ?? [];
              final completedList = userData['completedModules'] ?? [];
              final coins = userData['coins'] ?? userData['coins'] ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('modules')
                    .orderBy('id')
                    .snapshots(),
                builder: (context, moduleSnapshot) {
                  if (!moduleSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: softPink),
                    );
                  }

                  final moduls = moduleSnapshot.data!.docs;
                  final totalModules = moduls.length;
                  final completedCount = completedList.length;
                  final progress = totalModules == 0
                      ? 0.0
                      : (completedCount / totalModules).clamp(0.0, 1.0);

                      Map<String, dynamic>? currentModule;
                      for (final doc in moduls) {
                        final modul = doc.data() as Map<String, dynamic>;
                        final mId = modul['id'] ?? 0;

                        final isUnlocked =
                            (modul['price'] ?? 0) == 0 || unlockedList.contains(mId);
                        final isCompleted = completedList.contains(mId);

                        if (isUnlocked && !isCompleted) {
                          currentModule = modul;
                          break;
                        }
                      }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    itemCount: moduls.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildHeader(
                          context: context,
                          coins: coins,
                          completedCount: completedCount,
                          totalModules: totalModules,
                          progress: progress,
                          currentModule: currentModule,
                        );
                      }

                      if (index == moduls.length + 1) {
                        return _buildComingSoonCard();
                      }

                      final doc = moduls[index - 1];
                      final modul = doc.data() as Map<String, dynamic>;
                      final mId = modul['id'] ?? 0;

                      final isLocked =
                          (modul['price'] ?? 0) > 0 &&
                          !unlockedList.contains(mId);
                      final isDone = completedList.contains(mId);

                      return _buildModuleCard(
                        context: context,
                        modul: modul,
                        isLocked: isLocked,
                        isDone: isDone,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String? getYoutubeThumbnail(String? url) {
    if (url == null || url.isEmpty) return null;

    String? videoId;

    if (url.contains("watch?v=")) {
      videoId = url.split("watch?v=").last.split("&").first;
    } else if (url.contains("youtu.be/")) {
      videoId = url.split("youtu.be/").last.split("?").first;
    } else if (url.contains("/shorts/")) {
      videoId = url.split("/shorts/").last.split("?").first;
    }

    if (videoId == null || videoId.isEmpty) return null;

    return "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
  }

  Widget _buildHeader({
    required BuildContext context,
    required int coins,
    required int completedCount,
    required int totalModules,
    required double progress,
    required Map<String, dynamic>? currentModule,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Knit Nest",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 36,
                  color: cream,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: softLilac.withOpacity(0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: funkyPink.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: gold, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "$coins",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      color: cream,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        GestureDetector(
          onTap: currentModule == null
              ? null
              : () {
                  final mId = currentModule['id'] ?? 0;
                  final title = currentModule['title'] ?? "Untitled";
                  final desc = currentModule['description'] ?? "";
                  final videoUrl = currentModule['videoUrl'];
                  final String? videoThumbnail = getYoutubeThumbnail(videoUrl);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MateriDetailScreen(
                        modulId: mId,
                        title: title,
                        desc: desc,
                        videoUrl: videoUrl,
                      ),
                    ),
                  );
                },
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [softPink, softLilac],
              ),
              boxShadow: [
                BoxShadow(
                  color: softPink.withOpacity(0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentModule == null
                          ? "All modules completed!"
                          : "Continue learning",
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentModule == null
                          ? "Kamu sudah menyelesaikan semua modul yang tersedia ✨"
                          : currentModule['title'] ?? "Lanjutkan modul crochet kamu di sini ✨",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.35),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$completedCount/$totalModules modul selesai",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          "Learning Modules",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: cream,
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required Map<String, dynamic> modul,
    required bool isLocked,
    required bool isDone,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    final int mId = modul['id'] ?? 0;

    final String title = modul['title'] ?? "Untitled";
    final String desc = modul['description'] ?? "";
    final String? imageUrl = modul['imageUrl'];
    final String? videoUrl = modul['videoUrl'];
    final String level = modul['level'] ?? "Beginner";
    final int price = modul['price'] ?? 0;
    final int reward = modul['reward'] ?? 10;
    final String? videoThumbnail = getYoutubeThumbnail(videoUrl);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        List favList = [];

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          favList = data['favoriteModules'] ?? [];
        }

        final isFavorite = favList.contains(mId);

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 450),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () {
              if (isLocked) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModuleDetailScreen(moduleData: modul),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MateriDetailScreen(
                      modulId: mId,
                      title: title,
                      desc: desc,
                      videoUrl: videoUrl,
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: softLilac.withOpacity(0.34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: funkyPink.withOpacity(0.13),
                    blurRadius: 24,
                    offset: const Offset(0, 13),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [softPink, softLilac],
                            ),
                          ),
                          child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildImagePlaceholder(),
                              )
                            : videoThumbnail != null
                                ? Image.network(
                                    videoThumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildImagePlaceholder(),
                                  )
                                : _buildImagePlaceholder(),
                        ),

                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.36),
                              ],
                            ),
                          ),
                        ),

                        if (isLocked)
                          Container(
                            height: 150,
                            color: Colors.black.withOpacity(0.38),
                          ),

                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildPill(
                            text: level,
                            icon: Icons.local_florist_rounded,
                            color: softLilac,
                          ),
                        ),

                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () async {
                              if (user == null) return;

                              final docRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid);

                              if (isFavorite) {
                                await docRef.update({
                                  'favoriteModules':
                                      FieldValue.arrayRemove([mId])
                                });
                              } else {
                                await docRef.update({
                                  'favoriteModules':
                                      FieldValue.arrayUnion([mId])
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                ),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? funkyPink : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        if (videoUrl != null && videoUrl.isNotEmpty)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.90),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: darkPurple,
                                size: 30,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: cream,
                                ),
                              ),
                            ),
                            Icon(
                              isLocked
                                  ? Icons.lock_rounded
                                  : isDone
                                      ? Icons.check_circle_rounded
                                      : Icons.play_circle_fill_rounded,
                              color: isLocked
                                  ? Colors.white54
                                  : isDone
                                      ? mint
                                      : softPink,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.68),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPill(
                              text: isLocked ? "$price coins" : "Unlocked",
                              icon: isLocked
                                  ? Icons.stars_rounded
                                  : Icons.lock_open_rounded,
                              color: isLocked ? gold : mint,
                            ),
                            _buildPill(
                              text: "+$reward reward",
                              icon: Icons.card_giftcard_rounded,
                              color: funkyPink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.spa_rounded,
            color: Colors.white,
            size: 46,
          ),
          const SizedBox(height: 8),
          Text(
            "Crochet Preview",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: softLilac.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: softPink.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: softPink,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            "More cozy modules soon!",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: cream,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Modul crochet baru sedang disiapkan untuk journey kamu.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}