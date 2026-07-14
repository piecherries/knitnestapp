import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'materi_detail_screen.dart';
import '../widgets/floating_bubble.dart';
import '../main.dart';


class FavoriteModuleScreen extends StatelessWidget {
  const FavoriteModuleScreen({super.key});

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
            top: 160,
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
                        "Modul Favorit",
                        style: GoogleFonts.dmSerifDisplay(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, userSnapshot) {

                      if (!userSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF8FAB),
                          ),
                        );
                      }

                      List favIds =
                          userSnapshot.data?['favoriteModules'] ?? [];

                      if (favIds.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [

                              const Icon(
                                Icons.favorite_border,
                                color: Colors.white70,
                                size: 80,
                              ),

                              const SizedBox(height: 18),

                              Text(
                                "Belum ada modul favorit",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Tambahkan modul yang kamu sukai",
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('modules')
                            .where('id', whereIn: favIds)
                            .snapshots(),
                        builder: (context, moduleSnapshot) {

                          if (!moduleSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF8FAB),
                              ),
                            );
                          }

                          var favoriteModules =
                              moduleSnapshot.data!.docs;

                          return ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: favoriteModules.length,
                            itemBuilder: (context, index) {

                              var modul =
                                  favoriteModules[index].data()
                                      as Map<String, dynamic>;

                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.08),
                                  borderRadius:
                                      BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFD8C4FF)
                                        .withOpacity(.25),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF8FAB)
                                          .withOpacity(.12),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),

                                  leading: Container(
                                    padding:
                                        const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8FAB)
                                          .withOpacity(.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Color(0xFFFF8FAB),
                                    ),
                                  ),

                                  title: Text(
                                    modul['title'],
                                    style:
                                        GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                            top: 6),
                                    child: Text(
                                      modul['description'] ?? "",
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),

                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white70,
                                    size: 18,
                                  ),

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MateriDetailScreen(
                                          modulId:
                                              modul['id'],
                                          title:
                                              modul['title'],
                                          desc: modul[
                                              'description'],
                                          videoUrl:
                                              modul['videoUrl'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
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
}