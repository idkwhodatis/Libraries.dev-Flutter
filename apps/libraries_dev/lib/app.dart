import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'site/router.dart';

class LibrariesApp extends StatelessWidget {
  const LibrariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Libraries.dev',
      debugShowCheckedModeBanner: false,
      theme: buildSiteTheme(),
      routerConfig: appRouter,
    );
  }
}
