import 'package:flutter/material.dart';

class UIHelper {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  static void exitLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void showSnackBarNotify(
    BuildContext context,
    String title,
    Color colorNotify,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorNotify,
        showCloseIcon: true,
        content: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
