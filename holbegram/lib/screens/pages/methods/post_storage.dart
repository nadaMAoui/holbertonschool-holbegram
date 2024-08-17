import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPost(
    String caption,
    String uid,
    String username,
    String profImage,
    Uint8List image,
  ) async {
    try {
      // Create a unique file name
      final String fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef = _storage.ref().child(fileName);

      // Start the upload
      final UploadTask uploadTask = storageRef.putData(image);

      // Wait for upload completion
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      final String imageUrl = await snapshot.ref.getDownloadURL();

      // Add post details to Firestore
      final postDoc = await _firestore.collection('posts').add({
        'caption': caption,
        'uid': uid,
        'username': username,
        'profImage': profImage,
        'postUrl': imageUrl,
      });

      // Update user's posts array in Firestore
      await _firestore.collection('users').doc(uid).update({
        'posts': FieldValue.arrayUnion([postDoc.id]),
      });

      return 'Ok';
    } catch (e) {
      // Log the error and return the error message
      print('Error uploading post: $e');
      return e.toString();
    }
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
}
