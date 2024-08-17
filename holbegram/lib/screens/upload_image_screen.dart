import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:holbegram/providers/user_provider.dart';
import 'package:holbegram/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holbegram/methods/auth_methods.dart';
import 'package:provider/provider.dart';

class AddPicture extends StatefulWidget {
  final String email;
  final String username;
  final String password;

  AddPicture(
      {Key? key,
      required this.email,
      required this.username,
      required this.password})
      : super(key: key);

  @override
  _AddPictureState createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPicture> {
  Uint8List? _image;
  AuthMethods authMethods = AuthMethods();
  bool _isLoading = false;

  Future<void> selectImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = Uint8List.fromList(bytes);
      });
    }
  }

  Future<void> selectImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = Uint8List.fromList(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add a picture"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 28),
            Center(
              child: const Text(
                'Holbegram',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 50,
                ),
              ),
            ),
            Image.asset('assets/images/logo.webp', width: 80, height: 60),
            const SizedBox(
              height: 28,
            ),
            Text(
              "Hello, ${widget.username}, Welcome to Holbegram.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "choose an image from your gallery or take a new one.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            _image == null
                ? Image.asset(
                    "assets/images/Sample_User_Icon.png",
                    height: 250,
                    width: 250,
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: MemoryImage(_image!),
                      ),
                    )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.photo_outlined),
                  onPressed: (() => selectImageFromGallery()),
                  color: Color.fromARGB(218, 226, 37, 24),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt_outlined),
                  onPressed: (() => selectImageFromCamera()),
                  color: Color.fromARGB(218, 226, 37, 24),
                ),
              ],
            ),
            const SizedBox(
              height: 28,
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(218, 226, 37, 24),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        // Update this line
                        'next',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        String email = widget.email;
                        String username = widget.username;
                        String password = widget.password;

                        String result = await AuthMethods().signUpUser(
                          email: email,
                          password: password,
                          username: username,
                          file: _image,
                        );
                        print("image $_image");
                        if (result == "success") {
                          Provider.of<UserProvider>(context, listen: false)
                              .refreshUser();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result),
                          ));
                        }

                        setState(() {
                          _isLoading = false;
                        });
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
