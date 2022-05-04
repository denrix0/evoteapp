import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ButtonStyles {
  static ButtonStyle buttonNav() {
    return ButtonStyle(
        textStyle: MaterialStateProperty.all(TextStyles.textButtonStyle()));
  }

  static ButtonStyle defaultButton(BuildContext context) {
    return ButtonStyle(
        textStyle: MaterialStateProperty.all(TextStyles.textButtonStyle()),
        foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.background),
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
        padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)));
  }
}

class TextStyles {
  static TextStyle textDefaultStyle(BuildContext context, {Color? color, double? fontSize}) {
    return GoogleFonts.lato(fontSize: fontSize ?? 18.0, color: color);
  }

  static TextStyle textButtonStyle() {
    return GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle textTitleStyle() {
    return GoogleFonts.lato(fontSize: 32.0);
  }
}

class TextInputStyle {
  static genericField(String label, BuildContext context, {bool center = false}) {
    return InputDecoration(
        contentPadding: const EdgeInsets.all(20.0),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withAlpha(40),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        label: center ? Center(child: Text(label)) : Text(label),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
            borderRadius: BorderRadius.circular(8.0)),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0)));
  }

  static pinTheme(BuildContext context) {
    return PinTheme(
      activeColor: Theme.of(context).colorScheme.primary,
      selectedColor: Theme.of(context).colorScheme.secondary,
      inactiveColor: Theme.of(context).colorScheme.secondary,
      fieldWidth: 50,
      shape: PinCodeFieldShape.box,
      borderRadius: BorderRadius.circular(8.0)
    );
  }
}

class SnackBarStyles {
  static SnackBar errorSnackBar(BuildContext context, {required String content}) {
    return SnackBar(
      content: Text(content, textAlign: TextAlign.center,),
      backgroundColor: Theme.of(context).colorScheme.error,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      padding: const EdgeInsets.all(20.0),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20.0),
    );
  }
}
