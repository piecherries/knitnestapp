import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_notes_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  CollectionReference get notesRef => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('notes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140F1F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Crochet Notes",
          style: TextStyle(
            color: Color(0xFFFFF8F2),
            fontWeight: FontWeight.w800, 
          ),
        ),
      ),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: notesRef.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Terjadi kesalahan",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFB7D5),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final filteredDocs = snapshot.data!.docs.where((doc) {
                final note = doc.data() as Map<String, dynamic>;

                final title = (note['title'] ?? '').toString().toLowerCase();
                final desc = (note['desc'] ?? '').toString().toLowerCase();

                return title.contains(_searchQuery.toLowerCase()) ||
                    desc.contains(_searchQuery.toLowerCase());
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: filteredDocs.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHeader();

                  if (index == 1) return _buildSearchBar();

                  final noteDoc = filteredDocs[index - 2];
                  final note = noteDoc.data() as Map<String, dynamic>;

                  return _buildNoteCard(context, noteDoc.id, note);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF8FAB),
        elevation: 10,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditNoteScreen(notesRef: notesRef),
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "New",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search notes...",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(.5),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFFFB7D5),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: const Color(0xFFD8C4FF).withOpacity(.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color(0xFFFF8FAB),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB7D5),
            Color(0xFFD8C4FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB7D5).withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.library_books_rounded,
            color: Colors.white,
            size: 46,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Crochet Journal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Keep your patterns, materials, and project ideas neatly organized.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    String noteId,
    Map<String, dynamic> note,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD8C4FF).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8FAB).withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditNoteScreen(
              noteId: noteId,
              initialData: note,
              notesRef: notesRef,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB7D5),
                      Color(0xFFD8C4FF),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'] ?? "No Title",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFF8F2),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note['desc'] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB7D5).withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Project Note",
                        style: TextStyle(
                          color: Color(0xFFFFB7D5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Color(0xFFD8C4FF),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFD8C4FF).withOpacity(0.35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.note_alt_rounded,
                color: Color(0xFFFFB7D5),
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                "Tambah catatan di sini!",
                style: TextStyle(
                  color: Color(0xFFFFF8F2),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Simpan pola, jumlah row, jenis benang, atau ide project crochet pertama kamu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}