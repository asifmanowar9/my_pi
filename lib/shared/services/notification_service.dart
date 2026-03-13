// Platform selector for NotificationService.
// On platforms with dart:io (Android, iOS, desktop) the full implementation
// using flutter_local_notifications is used.  On web the no-op stub is used.
export 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart';
