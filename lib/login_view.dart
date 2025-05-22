import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_auth/ChangePasswordView.dart';
import 'package:face_auth/authenticate_face/authenticate_face_view.dart';
import 'package:face_auth/authenticate_face/user_details_view.dart';
import 'package:face_auth/common/utils/custom_snackbar.dart';
import 'package:face_auth/homeview.dart';
import 'package:face_auth/model/user_model.dart';
import 'package:face_auth/unifiedregisterview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:face_auth/Widget/bezierContainer.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: _emailController.text.trim())
          .where("password", isEqualTo: _passwordController.text.trim())
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final user = UserModel.fromJson(snapshot.docs.first.data());
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeView(user: user),
          ));
        } else {
          CustomSnackBar.errorSnackBar("Invalid credentials");
        }
      }).catchError((e) {
        CustomSnackBar.errorSnackBar("Login failed. Try again.");
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 7),
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
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter $title";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: _login,
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
        child: const Text('Login', style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Row(
        children: [
          SizedBox(width: 20),
          Expanded(child: Divider(thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('or'),
          ),
          Expanded(child: Divider(thickness: 1)),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _googleButton() {
        return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthenticateFaceView()));
      },
    child: Container(
      
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Color.fromARGB(255, 250, 252, 255),
      ),
      child:  Row(
        children: [
          Expanded(
            flex: 1,
           
                child: Image.asset(
                'assets/face.png',
                height: 40,
                width: 40,
              ),

          ),
          const Expanded(
            flex: 5,
            child: Center(
              child: Text('Log in with Face ID',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UnifiedRegisterView()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Text(
              'Register',
              style: TextStyle(color: Color(0xfff79c4f), fontSize: 13, fontWeight: FontWeight.w600),
            ),
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
          TextSpan(
            text: 'lock',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _entryField("Email", _emailController),
          _entryField("Password", _passwordController, isPassword: true),
        ],
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
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(height: 40),
                    _emailPasswordWidget(),
                    const SizedBox(height: 20),
                    _submitButton(),
                      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>  const ChangePasswordView(), // Replace with actual user
              ),
            );
          },
          child: const Text(
                            'Forgot Password ?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    _divider(),
                    _googleButton(),
                    const SizedBox(height: 10),
                    _createAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
