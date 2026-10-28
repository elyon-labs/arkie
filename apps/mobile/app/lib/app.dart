import 'package:arkie_mobile/features/servers/presentation/servers_page.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkie',
      debugShowCheckedModeBanner: false,
      theme: buildMobileTheme(),
      home: home ?? const ServersPage(),
    );
  }
}
