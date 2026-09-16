import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  const Button({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.colour,
    required this.textColour,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData icon;
  final Color colour;
  final Color textColour;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      label: Text(
        text,
        style: GoogleFonts.inter(fontSize: 20, color: textColour),
      ),
      icon: Icon(icon, size: 24, color: textColour),
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(5)),
        ),
        backgroundColor: colour,
      ),
    );
  }
}

class GreenButton extends Button {
  const GreenButton({
    required super.text,
    required super.onPressed,
    required super.icon,
    super.key,
  }) : super(colour: Colors.green, textColour: Colors.white);
}

class GrayButton extends Button {
  const GrayButton({
    required super.text,
    required super.onPressed,
    required super.icon,
    super.key,
  }) : super(colour: Colors.grey, textColour: Colors.black);
}

class RedButton extends Button {
  const RedButton({
    required super.text,
    required super.onPressed,
    required super.icon,
    super.key,
  }) : super(colour: Colors.redAccent, textColour: Colors.white);
}
