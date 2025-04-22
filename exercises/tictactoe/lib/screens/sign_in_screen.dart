import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'main_screen.dart';


class SignInScreen extends StatelessWidget {

 Future<void> _signInWithGoogle(BuildContext context) async {

   try {

     final GoogleSignIn googleSignIn = GoogleSignIn();

     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();


     if (googleUser == null) return; // User canceled sign-in


     final GoogleSignInAuthentication googleAuth =

         await googleUser.authentication;

     final AuthCredential credential = GoogleAuthProvider.credential(

       accessToken: googleAuth.accessToken,

       idToken: googleAuth.idToken,

     );


     await FirebaseAuth.instance.signInWithCredential(credential);

     Navigator.pushReplacement(

       context,

       MaterialPageRoute(builder: (context) => MainScreen()),

     );

   } catch (e) {

     ScaffoldMessenger.of(

       context,

     ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));

   }

 }


 @override

 Widget build(BuildContext context) {

   return Scaffold(

     appBar: AppBar(title: Text('Tic Tac Toe')),

     body: Center(

       child: ElevatedButton(

         onPressed: () => _signInWithGoogle(context),

         child: Text('Sign in with Google'),

       ),

     ),

   );

 }

}