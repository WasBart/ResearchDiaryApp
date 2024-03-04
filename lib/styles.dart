import 'package:flutter/material.dart';
import 'dart:math';

Color appBgColor = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8);
Color appPrimaryColor = const Color(0xFFE6590E).withOpacity(0.8);
Color appSecondaryColor = const Color(0xFF662806).withOpacity(0.8);
Color appTertiaryColor = const Color(0xFFEA8954).withOpacity(0.8);

ButtonStyle mainButtonStyle =
    ElevatedButton.styleFrom(backgroundColor: appPrimaryColor);

Container mainContainer({Widget? child}) {
  return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      height: 150,
      width: 200,
      decoration: BoxDecoration(
        color: appTertiaryColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
      ),
      child: child);
}

Container inactiveContainer({Widget? child}) {
  return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
      padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 134, 133, 133),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
      ),
      child: child);
}

Container variableContainer({Widget? child}) {
  return Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    width: 200,
    decoration: BoxDecoration(
      color: appTertiaryColor,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
    ),
    child: child,
  );
}
