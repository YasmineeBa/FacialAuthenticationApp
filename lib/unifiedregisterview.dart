import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_auth/Widget/bezierContainer.dart';
import 'package:face_auth/common/utils/custom_snackbar.dart';
import 'package:face_auth/common/utils/extract_face_feature.dart';
import 'package:face_auth/common/views/camera_viewpic.dart';
import 'package:face_auth/constants/theme.dart';
import 'package:face_auth/login_view.dart';
import 'package:face_auth/main.dart';
import 'package:face_auth/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:uuid/uuid.dart';

class UnifiedRegisterView extends StatefulWidget {
  const UnifiedRegisterView({Key? key}) : super(key: key);

  @override
  State<UnifiedRegisterView> createState() => _UnifiedRegisterViewState();
}

class _UnifiedRegisterViewState extends State<UnifiedRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _image;
  FaceFeatures? _faceFeatures;

  Future<void> _startCapture() async {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => CameraViewPic(
        onImage: (image) {
          setState(() {
            _image = base64Encode(image);
          });
        },
        onInputImage: (inputImage) async {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator(color: accentColor)),
          );
          _faceFeatures = await extractFaceFeatures(inputImage, _faceDetector);

          //always dismiss the loading dialog first
          if (mounted) Navigator.of(context).pop();

          //check if face features were detected
          if (_faceFeatures == null){
            CustomSnackBar.errorSnackBar("No face detected. Please try again with a clear face image.");
            return;
          }
          setState(() {});
        },
      ),
    ));
  }

  void _registerUser() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_image == null || _faceFeatures == null) {
        CustomSnackBar.errorSnackBar("Please capture your face first.");
        return;
      }

      FocusScope.of(context).unfocus();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: accentColor)),
      );

      try {
        String userId = const Uuid().v1();
        UserModel user = UserModel(
          id: userId,
          name: _nameController.text.trim().toUpperCase(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          image: _image!,
          faceFeatures: _faceFeatures!,
          registeredOn: DateTime.now().millisecondsSinceEpoch,
        );

        FirebaseFirestore.instance.collection("users").doc(userId).set(user.toJson()).then((_) {
          Navigator.of(context).pop();
          CustomSnackBar.successSnackBar("Registration Success");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Home()),
            (route) => false,
          );
        }).catchError((e) {
          Navigator.of(context).pop();
          CustomSnackBar.errorSnackBar("Registration Failed: ${e.toString()}");
        });
      } catch (e) {
        Navigator.of(context).pop();
        CustomSnackBar.errorSnackBar("Unexpected error: ${e.toString()}");
      }
    }
  }
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            const Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        text: 'face',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xffe46b10)),
        children: [
          TextSpan(text: 'lock', style: TextStyle(color: Colors.black, fontSize: 30)),
        ],
      ),
    );
  }


Widget _avatarWithCamera() {
  return SizedBox(
    width: 120,
    height: 120,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                _image != null ? MemoryImage(base64Decode(_image!)) : null,
            child: _image == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            onTap: _startCapture,
            child: Container(
              decoration: const BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}



  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: title,
              border: InputBorder.none,
              fillColor: const Color(0xfff3f3f4),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // 👈 smaller height

            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter $title' : null,
          )
        ],
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginView())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account ?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            SizedBox(width: 10),
            Text("Login", style: TextStyle(color: Color(0xfff79c4f), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,

      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.13),
                    _title(),
                    const SizedBox(height: 20),
                    _avatarWithCamera(),
                    const SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _entryField("Username", _nameController),
                          _entryField("Email", _emailController),
                          _entryField("Password", _passwordController, isPassword: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _registerUser,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              offset: const Offset(2, 4),
                              blurRadius: 5,
                              spreadRadius: 2,
                            )
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xfffbb448), Color(0xfff7892b)],
                          ),
                        ),
                        child: const Text('Register now', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

