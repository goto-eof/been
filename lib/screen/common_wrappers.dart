import 'package:flutter/material.dart';

class CommonWrappers {
  static Widget infoPane(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            end: Alignment.bottomRight,
            begin: Alignment.topLeft,
            colors: [
              Color.fromARGB(28, 179, 179, 179),
              Color.fromARGB(32, 206, 206, 206)
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
