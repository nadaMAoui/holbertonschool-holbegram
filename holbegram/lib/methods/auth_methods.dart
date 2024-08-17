import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:holbegram/models/user.dart';
import 'package:holbegram/screens/auth/methods/user_storage.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logOut() async {
    await _auth.signOut();
  }

  Future<String> login(
      {required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill all the fields';
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      Uint8List? file}) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return 'Please fill all the fields';
    }
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        String photoUrl = '';
        if (file != null) {
          photoUrl = await StorageMethods().uploadImageToStorage(
            false,
            'profileImages',
            file,
          );
        }

        await user.updateProfile(photoURL: photoUrl);

        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'uid': user.uid,
          'bio': '',
          'photoUrl': photoUrl,
          'followers': [],
          'following': [],
          'posts': [],
          'saved': [],
          'profImage': photoUrl,
          'searchKey': '',
        }).then((value) {
          print("User Added");
        }).catchError((error) {
          print("Failed to add user: $error");
        });

        return 'success';
      } else {
        return 'Error: User creation failed';
      }
    } catch (e) {
      print('Error in signUpUser: $e');
      return 'Error: $e';
    }
  }

  Future<Users?> getUserDetails() async {
    User? currentUser = _auth.currentUser;
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    return Users.fromSnap(documentSnapshot);
  }
}
