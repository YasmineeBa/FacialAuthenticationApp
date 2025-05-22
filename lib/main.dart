import 'package:face_auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:face_auth/authenticate_face/authenticate_face_view.dart';

import 'package:face_auth/common/utils/custom_snackbar.dart';

import 'package:face_auth/common/utils/screen_size_util.dart';
import 'package:face_auth/constants/theme.dart';
import 'package:face_auth/unifiedregisterview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Face Authentication App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(accentColor: accentColor),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(20),
          filled: true,
          fillColor: primaryWhite,
          hintStyle: TextStyle(
            color: primaryBlack.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
          errorStyle: const TextStyle(
            letterSpacing: 0.8,
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeUtilContexts(context);
  return Scaffold(
      body:SingleChildScrollView(
        child:Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: const Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
            
                    color: Colors.white,
            ),
                     // [Color(0xfffbb448), Color(0xffe46b10)])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
                      _title(context),
                      const SizedBox(height: 40),
                       _label(context),
                      const SizedBox(height: 80),
                      _loginButton(context),
                      const SizedBox(height: 20),
                      _registerButton(context),
                    
                     
                    ],
            ),
          ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xffdf8e33).withAlpha(100),
              offset: const Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
          color: Colors.white,
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
        ),
      ),
    );
  }

  Widget _registerButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UnifiedRegisterView()),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xffdf8e33).withAlpha(100),
              offset: const Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
          color: Colors.orange,
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _label(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: <Widget>[
         
          //const Icon(Icons.tag_faces, size: 90, color: Colors.orange),
           // Replacing icon with image
    
            GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthenticateFaceView()),
                          );
                        },
              child: Image.asset(
                'assets/face.png',
                height: 95,
                width: 95,
              ),
            ),
             const SizedBox(height: 30),
             const Text(
            'Quick login with Facial Recognition',
            style: TextStyle(color: Colors.black, fontSize: 17),
          ),
         

         /* const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthenticateFaceView()),
              );
            },
            child: const Text(
              'capture',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                decoration: TextDecoration.underline,
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'face',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline1,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color:const Color(0xfff7892b),
        ),
        children: const [
          TextSpan(
            text: 'lock',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ],
      ),
    );
  }
}

void initializeUtilContexts(BuildContext context) {
  ScreenSizeUtil.context = context;
  CustomSnackBar.context = context;
}
