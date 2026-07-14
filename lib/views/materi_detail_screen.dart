import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class MateriDetailScreen extends StatefulWidget {
  final int modulId;
  final String title;
  final String desc;
  final String? videoUrl;

  const MateriDetailScreen({
    super.key,
    required this.modulId,
    required this.title,
    required this.desc,
    this.videoUrl,
  });

  String? getYoutubeThumbnail(String? url) {
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);

  if (uri == null) return null;

  String? id;

  if (uri.queryParameters["v"] != null) {
      id = uri.queryParameters["v"];
    } else if (uri.host.contains("youtu.be")) {
      id = uri.pathSegments.first;
    } else if (uri.pathSegments.contains("shorts")) {
      id = uri.pathSegments.last;
    }

    if (id == null || id.isEmpty) return null;

    return "https://img.youtube.com/vi/$id/hqdefault.jpg";
  }

  @override
  State<MateriDetailScreen> createState() => _MateriDetailScreenState();
}

class _MateriDetailScreenState extends State<MateriDetailScreen> {
  bool _isFinished = false;
  late YoutubePlayerController _controller;

  static const darkBg = Color(0xFF140F1F);
  static const darkCard = Color(0xFF1E1830);
  static const softPink = Color(0xFFFFB7D5);
  static const funkyPink = Color(0xFFFF8FAB);
  static const softLilac = Color(0xFFD8C4FF);
  static const purple = Color(0xFF8E6CEF);
  static const mint = Color(0xFFB7D3B0);
  static const gold = Color(0xFFFFB703);

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl ?? "");
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "",
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _checkInitialStatus();
    _saveRecentModule();

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }

  Future<void> _checkInitialStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final completed = doc.data()?['completedModules'] ?? [];
      if (completed.contains(widget.modulId)) {
        setState(() => _isFinished = true);
      }
    }
  }

  Future<void> _saveRecentModule() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('recentModules')
      .doc(widget.modulId.toString())
      .set({
        'moduleId': widget.modulId,
        'title': widget.title,
        'description': widget.desc,
        'openedAt': FieldValue.serverTimestamp(),
      });
  }

  Future<void> _markAsDone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isFinished) return;

    try {
      setState(() => _isFinished = true);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'completedModules': FieldValue.arrayUnion([widget.modulId]),
        'coins': FieldValue.increment(10),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'modulId': widget.modulId,
        'moduleName': widget.title,
        'timestamp': FieldValue.serverTimestamp(),
        'progress': 100,
        'category': "Crochet",
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Text(
            "Lesson Completed!",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [softPink, softLilac],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Kamu mendapatkan 10 koin bonus karena menyelesaikan modul ini.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Oke",
                style: GoogleFonts.poppins(
                  color: funkyPink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Gagal update koin: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 125),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  _buildHeroVideoCard(),
                  const SizedBox(height: 24),
                  _buildTitleSection(),
                  const SizedBox(height: 22),
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Step-by-step Guide"),
                  const SizedBox(height: 14),
                  _buildStepItem(
                    "01",
                    "Siapkan hook dan benang sesuai kebutuhan modul.",
                    purple,
                  ),
                  _buildStepItem(
                    "02",
                    "Ikuti video tutorial dari awal sampai akhir.",
                    funkyPink,
                  ),
                  _buildStepItem(
                    "03",
                    "Praktikkan stitch dengan ritme pelan dan stabil.",
                    mint,
                  ),
                  _buildStepItem(
                    "04",
                    "Cek hasil akhir dan ulangi bagian yang masih sulit.",
                    gold,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Quick Notes"),
                  const SizedBox(height: 12),

                  _buildNoteCard(),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            "Learning Room",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  

  Widget _buildHeroVideoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: funkyPink,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 36,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.desc,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.6,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: softLilac.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: funkyPink.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: purple.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: purple,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFinished ? "Progress complete" : "Progress in learning",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _isFinished ? 1 : 0.35,
                    minHeight: 9,
                    backgroundColor: softLilac.withOpacity(0.25),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isFinished ? mint : funkyPink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSerifDisplay(
        fontSize: 27,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStepItem(String number, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: softLilac.withOpacity(0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: funkyPink.withOpacity(0.14),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: softPink.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: softPink,
            size: 32,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              "Jangan buru-buru. Crochet itu soal ritme, tension, dan kesabaran.",
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
      decoration: BoxDecoration(
        color: darkCard.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border(
          top: BorderSide(
            color: softLilac.withOpacity(0.18),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: funkyPink.withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _isFinished ? mint : funkyPink,
            disabledBackgroundColor: mint.withOpacity(0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _isFinished ? null : _markAsDone,
          child: Text(
            _isFinished ? "Already Completed" : "Mark as Completed +10",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}