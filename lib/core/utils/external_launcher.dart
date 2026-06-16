import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchExternalUrl(
  BuildContext context,
  String value, {
  String errorMessage = 'This file could not be opened on this device.',
}) async {
  final uri = Uri.tryParse(value);
  final messenger = ScaffoldMessenger.of(context);

  if (uri == null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage)));
    return;
  }

  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!didLaunch && context.mounted) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
