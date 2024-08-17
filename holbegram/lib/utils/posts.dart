import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holbegram/screens/pages/methods/post_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  Map<String, bool> likedPosts = {};
  int likes = 0;
  bool isLiked = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> data = snapshot.data!.docs;
          return SingleChildScrollView(
            child: Column(
              children: data.map((post) {
                String profImage = post['profImage'];
                String username = post['username'];
                String caption = post['caption'];
                String postUrl =
                    (post.data() as Map<String, dynamic>).containsKey('postUrl')
                        ? post['postUrl']
                        : '';
                String postId = post.id;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: NetworkImage(profImage),
                            ),
                            Text(username),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.bookmark),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser?.uid)
                                    .update({
                                  'savedPosts': FieldValue.arrayUnion([postId]),
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () async {
                                try {
                                  await PostStorage().deletePost(postId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Post Deleted'),
                                    ),
                                  );
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          child: Text(caption),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            image: DecorationImage(
                              image: NetworkImage(postUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(likedPosts[postId] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                              onPressed: () {
                                DocumentReference postRef =
                                    _firestore.collection('posts').doc(postId);
                                if (likedPosts[postId] == true) {
                                  postRef.update({
                                    'likes': FieldValue.increment(-1),
                                  }).then((_) {
                                    postRef
                                        .get()
                                        .then((DocumentSnapshot postSnapshot) {
                                      if (postSnapshot.exists) {
                                        var data = postSnapshot.data()
                                            as Map<String, dynamic>;
                                        if (data != null) {
                                          setState(() {
                                            likes = data['likes'];
                                            likedPosts[postId] = false;
                                          });
                                        }
                                      }
                                    });
                                  });
                                } else {
                                  postRef.update({
                                    'likes': FieldValue.increment(1),
                                  }).then((_) {
                                    postRef
                                        .get()
                                        .then((DocumentSnapshot postSnapshot) {
                                      if (postSnapshot.exists) {
                                        var data = postSnapshot.data()
                                            as Map<String, dynamic>;
                                        if (data != null) {
                                          setState(() {
                                            likes = data['likes'];
                                            likedPosts[postId] = true;
                                          });
                                        }
                                      }
                                    });
                                  });
                                }
                              },
                            ),
                            isLiked ? Text('1 like') : SizedBox.shrink(),
                            IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}