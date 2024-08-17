import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Favorite extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(currentUser?.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          List<String> savedPosts = List<String>.from(
              (snapshot.data?.data() as Map<String, dynamic>)?['savedPosts'] ??
                  []);

          return ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<DocumentSnapshot>(
                future:
                    _firestore.collection('posts').doc(savedPosts[index]).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  String postUrl = snapshot.data?['postUrl'] ?? '';

                  return Image.network(postUrl);
                },
              );
            },
          );
        },
      ),
    );
  }
}
