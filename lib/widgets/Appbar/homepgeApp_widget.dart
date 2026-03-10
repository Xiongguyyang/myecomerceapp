import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSizeWidget appBarWidget() {
  Future<Map<String, String>> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    final uid = user.uid;
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();
    if (!doc.exists) {
      return {'first': '', 'last': '', 'email': user.email ?? ''};
    }
    final data = doc.data() ?? {};
    return {
      'first': (data['FirstName'] ?? '') as String,
      'last': (data['LastName'] ?? '') as String,
      'email': (data['Email'] ?? user.email ?? '') as String,
    };
  }

  return AppBar(
    leadingWidth: 120,
    toolbarHeight: 88,
    centerTitle: true,
    backgroundColor: const Color.fromARGB(0, 4, 101, 205),
    leading: FutureBuilder<Map<String, String>>(
      future: loadUser(),
      builder: (context, snapshot) {
        String first = '';
        String last = '';
        String email = '';
        if (snapshot.hasData) {
          first = snapshot.data!['first'] ?? '';
          last = snapshot.data!['last'] ?? '';
          email = snapshot.data!['email'] ?? '';
        }

        // compute initials
        String initials = first;
        if (first.isEmpty) initials += last.toUpperCase();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: GestureDetector(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Account'),
                  content: Text(
                    'First name: $first\nLast name: $last\nEmail: $email',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blueGrey,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        );
      },
    ),
    title: Container(
      child: Text(
        'Flex JK',
        style: GoogleFonts.notoSans(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    actions: [
      IconButton(
        iconSize: 40,
        color: const Color.fromARGB(255, 255, 255, 255),
        alignment: Alignment.topLeft,
        onPressed: () {},
        icon: const Icon(Icons.shopping_cart),
      ),
    ],
  );
}
