import 'package:flutter/material.dart';
import 'package:bmi_tracker/core/widgets/custom_card.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Responsive width limit for tablet/web
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: CustomCard(child: child),
    );
  }
}
