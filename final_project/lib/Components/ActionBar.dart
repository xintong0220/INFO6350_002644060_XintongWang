// lib/Components/ActionBar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project/Pages/LoginScreen.dart';

class ActionBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showAuthButton;
  final VoidCallback? onBackPressed;

  const ActionBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showAuthButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading:
          showBackButton
              ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: onBackPressed ?? () => Get.back(),
              )
              : null,
      actions: showAuthButton ? [_buildAuthButton()] : [],
    );
  }

  Widget _buildAuthButton() {
    // use StreamBuilder to listen to log in status changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // check if logged in
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            // signed out -- show log in button
            return IconButton(
              icon: Icon(Icons.login),
              tooltip: 'Login',
              onPressed: () {
                Get.to(() => LoginScreen());
              },
            );
          } else {
            // signed in -- show log out button
            return IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                _handleLogout();
              },
            );
          }
        } else {
          // loading
          return Container(
            padding: EdgeInsets.all(8),
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.snackbar(
        'Success',
        'You have successfully logged out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
