// Platform selector for NotificationDebugPage.
// On platforms with dart:io (Android, iOS, desktop) the full debug page is
// used.  On web a simple placeholder widget is shown.
export 'notification_debug_page_stub.dart'
    if (dart.library.io) 'notification_debug_page_mobile.dart';
