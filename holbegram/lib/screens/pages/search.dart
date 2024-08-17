import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search...",
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: 32,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (searchQuery != '')
            ? _firestore
                .collection('posts')
                .where('caption', isGreaterThanOrEqualTo: searchQuery)
                .snapshots()
            : _firestore.collection('posts').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return Image.network(
                  snapshot.data?.docs[index].get('postUrl') ?? '');
            },
            staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
          );
        },
      ),
    );
  }
}
