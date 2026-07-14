import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../widgets/floating_bubble.dart';

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF140F1F),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Stack(
          children: [

            const FloatingBubble(
              size: 170,
              color: Color(0xFFFF8FAB),
              top: -30,
              left: -20,
            ),

            const FloatingBubble(
              size: 120,
              color: Color(0xFFD8C4FF),
              top: 150,
              left: 280,
            ),

            const FloatingBubble(
              size: 100,
              color: Color(0xFFFFB7D5),
              top: 650,
              left: -10,
            ),

            SafeArea(
              child: Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Text(
                          "Riwayat Belajar 📚",
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .collection('history')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF8FAB),
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {

                            var data = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                            return _buildHistoryCard(data);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    DateTime? date =
        (data['timestamp'] as Timestamp?)?.toDate();

    String formattedDate = date != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(date)
        : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD8C4FF).withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8FAB).withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),

        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8FAB).withOpacity(.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFFFF8FAB),
          ),
        ),

        title: Text(
          data['moduleName'] ?? "Modul",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            "Selesai pada\n$formattedDate",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8FAB).withOpacity(.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "+10 🪙",
            style: GoogleFonts.poppins(
              color: const Color(0xFFFFB7D5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.history_edu,
            color: Colors.white54,
            size: 90,
          ),

          const SizedBox(height: 18),

          Text(
            "Belum ada riwayat belajar",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Selesaikan modul pertamamu untuk mulai mengumpulkan riwayat 📚",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}