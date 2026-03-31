import 'package:flutter/material.dart';

class Responsive {
  // Screen dimensions
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Device type checks
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isNormalPhone(BuildContext context) =>
      MediaQuery.of(context).size.width >= 360 &&
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  // Responsive font size
  static double fontSize(BuildContext context, double size) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return size * 0.85;
    if (w >= 600) return size * 1.2;
    return size;
  }

  // Responsive padding
  static double padding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 14;
    if (w >= 600) return 32;
    return 20;
  }

  // Responsive icon size
  static double iconSize(BuildContext context, double size) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return size * 0.85;
    if (w >= 600) return size * 1.3;
    return size;
  }

  // Responsive border radius
  static double radius(BuildContext context, double radius) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return radius * 0.85;
    if (w >= 600) return radius * 1.2;
    return radius;
  }

  // Responsive spacing
  static double spacing(BuildContext context, double space) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return space * 0.75;
    if (w >= 600) return space * 1.5;
    return space;
  }

  // Responsive width percentage
  static double wp(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * percent / 100;

  // Responsive height percentage
  static double hp(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * percent / 100;
}