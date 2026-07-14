import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

const String defaultImage = "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=1200";

class ModuleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;
  const ModuleDetailScreen({super.key, required this.moduleData});
    static const softLilac = Color(0xFFD8C4FF);
    static const funkyPink = Color(0xFFFF8FAB);

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  bool _isProcessing = false;

  Future<void> _processPurchase(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final currentCoins =
          userDoc.data()?['coins'] ?? userDoc.data()?['coins'] ?? 0;

      final price = widget.moduleData['price'] ?? 0;

      if (currentCoins < price) {
        _showSnackBar("Koin kamu belum cukup. Top up dulu ya ✨");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'coins': FieldValue.increment(-price),
        'unlockedModuls': FieldValue.arrayUnion([widget.moduleData['id']]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'title': "Unlock: ${widget.moduleData['title']}",
        'amount': -price,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccessDialog(context);
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String? getYoutubeThumbnail(String? url) {
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);

    if (uri == null) return null;

    String? videoId;

    if (uri.queryParameters['v'] != null) {
      videoId = uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      videoId = uri.pathSegments.first;
    } else if (uri.pathSegments.contains('shorts')) {
      videoId = uri.pathSegments.last;
    }

    if (videoId == null || videoId.isEmpty) return null;

    return "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF8E6CEF),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1830),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          "Module Unlocked! ✨",
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        content: Text(
          "Sekarang kamu bisa belajar modul ini langsung di dalam app.",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8FAB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "Mulai Belajar",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.moduleData['title'] ?? "Crochet Module";
    final desc = widget.moduleData['description'] ?? "Deskripsi belum tersedia.";
    final price = widget.moduleData['price'] ?? 0;
    final reward = widget.moduleData['reward'] ?? 10;
    final level = widget.moduleData['level'] ?? "Beginner";
    final hookSize = widget.moduleData['hookSize'] ?? "3.5mm";
    final yarnType = widget.moduleData['yarnType'] ?? "Milk Cotton";
    final String? videoUrl = widget.moduleData['videoUrl'];
    final String? thumbnail = getYoutubeThumbnail(videoUrl);
    

    return Scaffold(
      backgroundColor: const Color(0xFF140F1F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF140F1F),
              Color(0xFF2B164A),
              Color(0xFF4A1D4F),
              Color(0xFF1A1533),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: const Color(0xFF1A1533),
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          thumbnail ?? defaultImage,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.25),
                                const Color(0xFFFFF8F2),
                              ],
                              stops: const [0.28, 0.72, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 26,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBadge(level, const Color(0xFF8E6CEF)),
                              const SizedBox(height: 12),
                              Text(
                                title,
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 38,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Unlock this cozy lesson and start creating inside Knit Nest.",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.92),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.play_circle_rounded,
                                title: "Video",
                                subtitle: "Step guide",
                                color: const Color(0xFF8E6CEF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.handyman_rounded,
                                title: "Tools",
                                subtitle: "Hook & yarn",
                                color: const Color(0xFFFF8FAB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.stars_rounded,
                                title: "+$reward",
                                subtitle: "Reward",
                                color: const Color(0xFFFFB703),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        _buildSectionTitle("About This Module"),
                        const SizedBox(height: 10),
                        Text(
                          desc,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            height: 1.7,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _buildSectionTitle("What You’ll Learn"),
                        const SizedBox(height: 12),
                        _buildLearnItem(
                          "Step-by-step crochet process inside the app",
                          const Color(0xFF8E6CEF),
                        ),
                        _buildLearnItem(
                          "Cara membaca instruksi pola dengan lebih mudah",
                          const Color(0xFFFF8FAB),
                        ),
                        _buildLearnItem(
                          "Tips menjaga tension dan bentuk stitch tetap rapi",
                          const Color(0xFFB7D3B0),
                        ),

                        const SizedBox(height: 28),

                        // _buildSectionTitle("Tools Needed"),
                        // const SizedBox(height: 12),
                        // Wrap(
                        //   spacing: 10,
                        //   runSpacing: 10,
                        //   children: [
                        //     _buildToolChip("Hook $hookSize", const Color(0xFF8E6CEF)),
                        //     _buildToolChip(yarnType, const Color(0xFFFF8FAB)),
                        //     _buildToolChip(level, const Color(0xFFFFB703)),
                        //   ],
                        // ),

                        // const SizedBox(height: 28),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFB7D5),
                                Color(0xFFD8C4FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_open_rounded,
                                  color: Color(0xFF8E6CEF),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  "Setelah unlock, modul ini akan masuk ke learning path kamu.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1830).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.14),
                      blurRadius: 22,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: ModuleDetailScreen.softLilac.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ModuleDetailScreen.funkyPink.withOpacity(0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFFFB703),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$price",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF8FAB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : () => _processPurchase(context),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  "Unlock Module",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8C4FF).withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSerifDisplay(
        fontSize: 27,
         color: Colors.white,
      ),
    );
  }

  Widget _buildLearnItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}