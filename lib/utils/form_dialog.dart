import 'package:flutter/material.dart';

// The height of your navigation bar
const double kNavbarHeight = 110.0;

// This function will show your form from the top of the navigation bar
Future<void> showFormFromNavbar(BuildContext context, Widget formContent) {
  return showGeneralDialog(
    context: context,
    barrierColor: Colors.black54, // The background overlay color
    barrierDismissible: true, // Dismissible by tapping outside
    barrierLabel: 'Form Dialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      // The content of the dialog
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: kNavbarHeight),
          child: formContent,
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      // Use a slide transition for a smooth animation
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(anim1),
        child: child,
      );
    },
  );
}
