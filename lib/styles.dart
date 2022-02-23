import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonStyles {

  static ButtonStyle buttonStyleNav() {
    return ButtonStyle(
      textStyle: MaterialStateProperty.all(TextStyles.textButtonStyle())
    );
  }
}

class TextStyles {
  static TextStyle textDefaultStyle() {
    return GoogleFonts.lato(
      fontSize: 18.0
    );
  }

  static TextStyle textButtonStyle() {
    return GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.bold
    );
  }

  static TextStyle textTitleStyle() {
    return GoogleFonts.lato(
      fontSize: 32.0
    );
  }
}