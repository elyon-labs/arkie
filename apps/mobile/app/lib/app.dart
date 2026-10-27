import 'package:arkie_mobile/core/theme.dart';
import 'package:arkie_mobile/features/servers/presentation/servers_page.dart';
import 'package:flutter/material.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkie',
      debugShowCheckedModeBanner: false,
      theme: buildArkieTheme(),
      home: home ?? const ServersPage(),
    );
  }
}
