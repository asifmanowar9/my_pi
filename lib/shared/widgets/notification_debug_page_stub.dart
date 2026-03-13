// Web stub for NotificationDebugPage.
// Local-notification debugging is a mobile-only concern.

import 'package:flutter/material.dart';

class NotificationDebugPage extends StatelessWidget {
  const NotificationDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Debug')),
      body: const Center(
        child: Text('Notifications are not available on web.'),
      ),
    );
  }
}
