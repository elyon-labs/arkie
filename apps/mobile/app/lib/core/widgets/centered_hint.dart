import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// A muted, centered message for empty or unavailable states.
class CenteredHint extends StatelessWidget {
  const CenteredHint(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.muted, height: 1.5),
        ),
      ),
    );
  }
}
