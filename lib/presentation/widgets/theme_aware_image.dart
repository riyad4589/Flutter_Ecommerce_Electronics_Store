import 'package:flutter/material.dart';

/// Widget qui affiche une image différente selon le thème actuel (clair ou sombre)
class ThemeAwareImage extends StatelessWidget {
  final String lightImagePath;
  final String darkImagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ThemeAwareImage({
    super.key,
    required this.lightImagePath,
    required this.darkImagePath,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final imagePath =
        brightness == Brightness.light ? lightImagePath : darkImagePath;

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
