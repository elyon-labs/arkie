import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// The right-hand pane. Its label names what the pane is for, the way the
/// console pane carries the server's name.
class SidebarWrapper extends StatelessWidget {
  const SidebarWrapper({super.key, required this.child, this.label = 'status'});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TerminalPanel(label: label, padding: EdgeInsets.zero, child: child);
  }
}
