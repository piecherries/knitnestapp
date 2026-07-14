import 'package:flutter/material.dart';
import 'modul_screen.dart'; 
import 'notes_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD8C4FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- FUNGSI KLAIM LOGIKA BARU (STREAK & RESET) ---
  Future<void> handleDailyClaim() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      var userDoc = await userRef.get();
      
      if (!userDoc.exists) return;
      var data = userDoc.data()!;

      DateTime now = DateTime.now();
      String today = DateFormat('yyyy-MM-dd').format(now);
      
      String lastClaim = data['lastClaimDate'] ?? "";
      int currentStreak = data['streak'] ?? 0;
      int currentKoin = data['coins'] ?? 0;

      if (lastClaim == today) {
        _showSnackBar("Sudah klaim hari ini! Balik lagi besok ya 🧶");
        return;
      }

      // Cek apakah bolong/skip login
      if (lastClaim != "") {
        DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastClaim);
        int diff = now.difference(lastDate).inDays;

        if (diff > 1) {
          currentStreak = 0; // Reset ke nol kalau skip
        }
      }

      int newStreak = currentStreak + 1;
      if (newStreak > 7) newStreak = 1; // Balik ke Day 1 kalau sudah lewat Day 7

      // Bonus: Day 7 dapet 500, hari lain 100
      int bonusKoin = (newStreak == 7) ? 100 : 10;

      await userRef.update({
        'coins': currentKoin + bonusKoin,
        'streak': newStreak,
        'lastClaimDate': today,
      });

      _showSnackBar("Day $newStreak Berhasil! +$bonusKoin Koin ✨");
      
    } catch (e) {
      _showSnackBar("Gagal klaim: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita kirim handleDailyClaim ke ProfileScreen
    final List<Widget> _pages = [
      const ModulScreen(),
      const NotesScreen(),
      ProfileScreen(onClaim: handleDailyClaim), 
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF2B164A),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sticky_note_2_rounded), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}