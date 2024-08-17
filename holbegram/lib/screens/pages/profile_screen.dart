import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:holbegram/models/posts.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:holbegram/methods/auth_methods.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  List<dynamic> postsIds = [];

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    widget.postsIds = userProvider.getUser!.posts;
    Future<List<DocumentSnapshot>?> getPosts() async {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection('posts');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      widget.postsIds = userProvider.getUser!.posts;
      if (widget.postsIds.isNotEmpty) {
        final query =
            collection.where(FieldPath.documentId, whereIn: widget.postsIds);
        final querySnapshot = await query.get();
        return querySnapshot.docs;
      } else {
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 40,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthMethods().logOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    ((route) => false));
              },
              icon: const Icon(Icons.logout_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userProvider.getUser!.photoUrl != ""
                        ? NetworkImage(userProvider.getUser!.photoUrl)
                        : Image.asset("assets/images/img.png").image,
                  ),
                  FollwItem(
                      text: "Posts",
                      count: userProvider.getUser!.postCount.toString()),
                  FollwItem(
                      text: "Followers",
                      count: userProvider.getUser!.followers.length.toString()),
                  FollwItem(
                      text: "Following",
                      count: userProvider.getUser!.following.length.toString()),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                child: Text(
                  "${userProvider.getUser!.username}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 600,
                child: FutureBuilder(
                    future: getPosts()
                        .then((value) => widget.postsIds = value ?? []),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final posts = snapshot.data;

                      if (posts!.isEmpty) {
                        return Center(child: Text('No posts available.'));
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final Post post = Post.fromSnap(posts[index]);
                          return Image.network(
                            post.postUrl,
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FollwItem extends StatelessWidget {
  final String text;
  final String count;
  const FollwItem({super.key, required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          text,
          style: TextStyle(
              color: Colors.grey, fontSize: 20, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
