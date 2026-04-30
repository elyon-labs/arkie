import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
import 'package:flutter/material.dart';

class SidebarWrapper extends StatelessWidget {
  const SidebarWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RoundedSuperellipseBox(color: context.colors.modal, child: child);
  }
}
