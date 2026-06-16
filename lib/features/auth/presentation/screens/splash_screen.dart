import 'package:flutter/material.dart';

import '../../../../core/widgets/app_loading_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = 'splash';
  static const routePath = '/splash';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppLoadingView());
  }
}
