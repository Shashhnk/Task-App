import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final kTextStyle = TextStyle(
  fontWeight: FontWeight.w600,
  fontFamily: sora,
);


final sora = GoogleFonts.sora().fontFamily;

final List<Map<String, String>> pages = [
  {
    "title": "Get things done.",
    "subtitle": "Just a click away from planning your tasks."
  },
  {"title": "Stay Organized.", "subtitle": "Manage your tasks efficiently."},
  {"title": "Achieve Goals.", "subtitle": "Track progress and stay motivated."},
];

Container buildDot(int index, int currentIndex) {
  return Container(
    height: currentIndex == index ? 10 : 7,
    width: currentIndex == index ? 10 : 7,
    margin: const EdgeInsets.only(right: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(currentIndex == index ? 10 : 7),
      color: Colors.deepPurple.withOpacity(currentIndex == index ? 1 : 0.2),
    ),
  );
}


bool emailValidate(String email) {
  RegExp emailexp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  return emailexp.hasMatch(email);
}



