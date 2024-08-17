import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/screens/pages/methods/post_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddImage extends StatefulWidget {
  @override
  State<AddImage> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddImage> {
  bool showIcons = false;

  void toggleIcons() {
    setState(() {
      showIcons = !showIcons;
    });
  }

  final TextEditingController captionController = TextEditingController();

  Uint8List? _image;

  void selectImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        _image = bytes;
      });
    }
  }

  void selectImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        _image = bytes;
      });
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add Image",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  if (_image != null &&
                      FirebaseAuth.instance.currentUser != null) {
                    String result = await PostStorage().uploadPost(
                      captionController.text,
                      FirebaseAuth.instance.currentUser!.uid,
                      FirebaseAuth.instance.currentUser!.displayName ?? '',
                      FirebaseAuth.instance.currentUser!.photoURL ?? '',
                      _image!,
                    );
                    if (result == 'Ok') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Post uploaded successfully!'),
                        ),
                      );
                      userProvider.incrementPostCount();
                      Navigator.pushNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please select an image and make sure you are logged in'),
                      ),
                    );
                  }
                },
                child: Text(
                  "Post",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[200],
                    fontFamily: 'Billabong',
                  ),
                ),
              ),
            ), //
            //
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const Text(
                  'Add Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Choose an image from your gallery or take one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: captionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption ...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      toggleIcons();
                    },
                    child: _image != null
                        ? Image.memory(
                            _image!,
                            width: 300,
                            height: 200,
                          )
                        : Image.network(
                            'https://cdn.pixabay.com/photo/2017/11/10/05/24/add-2935429_960_720.png',
                            width: 150,
                            height: 150,
                          ),
                  ),
                ),
              ],
            ),
            if (showIcons)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.photo_outlined,
                              size: 48, color: Colors.red),
                          onPressed: (() => selectImageFromGallery())),
                      Text(
                        "Gallery",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      IconButton(
                          icon: Icon(Icons.camera_alt_outlined,
                              size: 48, color: Colors.red),
                          onPressed: (() => selectImageFromCamera())),
                      Text(
                        "Camera",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }
}
