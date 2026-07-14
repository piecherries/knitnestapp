// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// const Color darkBg = Color(0xFF1E1830);
// const Color softPink = Color(0xFFFFB7D5);
// const Color funkyPink = Color(0xFFFF8FAB);
// const Color softLilac = Color(0xFFD8C4FF);
// const Color gold = Color(0xFFFFB703);

// void showPurchaseSheet(BuildContext context, Map<String, dynamic> module, int userCoins, String userId, String moduleId) {
//   final Color sageTua = const Color(0xFF5A6344);
//   final Color sageMuda = const Color(0xFF8E9775);
//   final int hargaModul = module['price'] ?? 0;

//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (context) => Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: darkBg,
//         borderRadius: const BorderRadius.vertical(
//           top: Radius.circular(32),
//         ),
//         border: Border.all(
//           color: softLilac.withOpacity(.2),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40, height: 4,
//             decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
//           ),
//           const SizedBox(height: 25),
//           CircleAvatar(
//             radius: 35,
//             backgroundColor: const Color(0xFFF0F2F0),
//             child: Icon(Icons.auto_stories, color: sageMuda, size: 35),
//           ),
//           const SizedBox(height: 15),
//           Text("Buka Modul Ini?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: sageTua)),
//           const SizedBox(height: 8),
//           Text("Pola '${module['title']}' akan terbuka selamanya setelah kamu beli.",
//             textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
//           const SizedBox(height: 20),

//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F9FC),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Colors.grey.shade200,
//               ),
//             ),
//             child: Column(
//               children: [

//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.withOpacity(.15),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.workspace_premium,
//                         color: Colors.orange,
//                       ),
//                     ),

//                     const SizedBox(width: 15),

//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [

//                           Text(
//                             module["title"],
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),

//                           const SizedBox(height: 5),

//                           Text(
//                             "Modul akan terbuka permanen",
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 18),

//                 const Divider(),

//                 const SizedBox(height: 12),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [

//                     const Text("Harga"),

//                     Row(
//                       children: [
//                         const Icon(Icons.stars,color: Colors.amber),
//                         const SizedBox(width:5),
//                         Text(
//                           "$hargaModul",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 17,
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),

//                 const SizedBox(height:10),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [

//                     const Text("Koin kamu"),

//                     Text(
//                       "$userCoins",
//                       style: TextStyle(
//                         color: userCoins>=hargaModul
//                             ? Colors.green
//                             : Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17,
//                       ),
//                     )
//                   ],
//                 ),

//                 const SizedBox(height:10),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [

//                     const Text(
//                       "Sisa setelah beli",
//                     ),

//                     Text(
//                       "${userCoins-hargaModul}",
//                       style: TextStyle(
//                         color: userCoins>=hargaModul
//                             ? Colors.green
//                             : Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17,
//                       ),
//                     )
//                   ],
//                 ),

//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     ),
//   );
// }