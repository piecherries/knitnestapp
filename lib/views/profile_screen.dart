import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'topup_screen.dart';
import 'learning_history_screen.dart';
import 'favorite_module_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onClaim;
  const ProfileScreen({super.key, required this.onClaim});

  static const darkBg = Color(0xFF140F1F);
  static const darkCard = Color(0xFF1E1830);
  static const softPink = Color(0xFFFFB7D5);
  static const funkyPink = Color(0xFFFF8FAB);
  static const softLilac = Color(0xFFD8C4FF);
  static const purple = Color(0xFF8E6CEF);
  static const gold = Color(0xFFFFB703);
  static const mint = Color(0xFF65B891);


  void _showEditAccountModal(
    BuildContext context,
    String currentName,
    String? email,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    final TextEditingController nameController = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Edit Akun",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Informasi Profil",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: const Icon(Icons.person_outline, color: funkyPink),
                  labelStyle: const TextStyle(color: softPink),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: softLilac.withOpacity(0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: funkyPink, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Keamanan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_reset_rounded, color: gold),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ganti Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Link reset password akan dikirim ke email kamu.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        print("Tombol Kirim ditekan");
                        print("Email: $email");

                        try {
                          if (email == null || email.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Email tidak ditemukan."),
                              ),
                            );
                            return;
                          }

                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );

                          if (!context.mounted) return;

                          await _showInfoDialog(
                            context,
                            title: "Email Berhasil Dikirim",
                            message:
                                "Email reset password telah dikirim ke:\n\n$email\n\nCek Inbox atau folder Spam jika belum terlihat.",
                          );
                        } on FirebaseAuthException catch (e) {
                          print("Firebase Error");
                          print("Code: ${e.code}");
                          print("Message: ${e.message}");

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(e.message ?? e.code),
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Kirim",
                        style: TextStyle(
                          color: gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: funkyPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    print("Tombol Simpan diklik");

                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      print("User null");
                      return;
                    }

                    final newName = nameController.text.trim();

                    if (newName.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Nama tidak boleh kosong")),
                      );
                      return;
                    }

                    try {
                      print("Update Firestore...");

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        "name": newName,
                      });

                      print("Berhasil update");

                      if (!context.mounted) return;

                      Navigator.pop(sheetContext);

                      await _showInfoDialog(
                        context,
                        title: "Profil Berhasil Diperbarui",
                        message:
                            "Nama profil telah diperbarui.",
                      );
                    } catch (e) {
                      print(e);

                      messenger.showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Log Out",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "Yakin ingin keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Tidak", style: TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: funkyPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(
                color: funkyPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required int favoriteCount,
    required int historyCount,
  }) {
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: softLilac.withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: funkyPink.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "My Crochet Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),

          /// statistik kecil
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteModuleScreen(),
                      ),
                    );
                  },
                  child: _buildMiniStat(
                    Icons.favorite_rounded,
                    "$favoriteCount",
                    "Favorites",
                    funkyPink,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearningHistoryScreen(),
                      ),
                    );
                  },
                  child: _buildMiniStat(
                    Icons.history_edu_rounded,
                    "$historyCount",
                    "History",
                    softLilac,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDailyEvent(Map<String, dynamic> userData) {
    final int currentStreak = userData['streak'] ?? 0;
    final String lastClaim = userData['lastClaimDate'] ?? "";
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final bool alreadyClaimedToday = lastClaim == today;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [softPink, softLilac],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: funkyPink.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Daily Rewards ✨",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  "$currentStreak Days",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final isClaimed = day <= currentStreak;
                  final isToday = day == currentStreak + 1 && !alreadyClaimedToday;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.white
                          : Colors.white.withOpacity(isClaimed ? 0.25 : 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Day $day",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isToday ? darkBg : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          day == 7
                              ? Icons.redeem_rounded
                              : isClaimed
                                  ? Icons.check_circle_rounded
                                  : Icons.savings_outlined,
                          color: isToday ? funkyPink : Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day == 7 ? "+100" : "+10",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isToday ? darkBg : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: alreadyClaimedToday ? null : onClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: funkyPink,
                  disabledBackgroundColor: Colors.white.withOpacity(0.35),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  alreadyClaimedToday ? "Sampai Jumpa Besok!" : "Klaim Reward",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: softLilac.withOpacity(0.22)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 23),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }

  Widget _buildCoinCard(BuildContext context, int userKoin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: softLilac.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: funkyPink.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: gold, size: 20),
          const SizedBox(width: 6),
          Text(
            "$userKoin",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          // const SizedBox(width: 10),
          // GestureDetector(
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => const TopUpScreen()),
          //   ),
          //   child: Container(
          //     padding: const EdgeInsets.all(4),
          //     decoration: const BoxDecoration(
          //       color: funkyPink,
          //       shape: BoxShape.circle,
          //     ),
          //     child: const Icon(Icons.add, color: Colors.white, size: 15),
          //   ),
          // ),
        ],
      ),
    );
  }

  

  Widget _buildMiniStat(
    IconData icon,
    String value,
    String title,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: funkyPink),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
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
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: softPink),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    "User data not found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final int userKoin = userData['coins'] ?? 0;
              
              final favoriteList = userData['favoriteModules'] ?? [];

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('history')
                    .snapshots(),
                builder: (context, historySnapshot) {
                  if (historySnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: softPink),
                    );
                  }

                  final historyCount = historySnapshot.data?.docs.length ?? 0;
    
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: softLilac.withOpacity(0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: funkyPink.withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 45,
                                backgroundColor: funkyPink,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userData['name'] ?? "User",
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user?.email ?? "",
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildCoinCard(context, userKoin),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildDailyEvent(userData),
                        const SizedBox(height: 26),
                        _buildDashboardCard(
                          context: context,
                          favoriteCount: favoriteList.length,
                          historyCount: historyCount,
                          // historyCount: learningCount,
                        ),

                        const SizedBox(height: 32),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Pengaturan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        
                        _buildMenuTile(
                          icon: Icons.manage_accounts_rounded,
                          title: "Edit Akun",
                          subtitle: "Ubah nama atau reset password",
                          color: softLilac,
                          onTap: () => _showEditAccountModal(
                            context,
                            userData['name'] ?? "",
                            user?.email,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );    
            },
          ),
        ),
      ),
    );
  }
}