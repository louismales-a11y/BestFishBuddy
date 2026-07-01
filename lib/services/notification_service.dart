import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles push notifications for weather alerts, solunar reminders, etc.
/// Silent failure — never crashes.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (iOS)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token (for sending notifications later)
      final token = await messaging.getToken();
      if (token != null) {
        // Store token in Firestore for future server-side notifications
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _storeToken(uid, token);
        }
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Handle notification taps (app opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    } catch (_) {
      // Silent fail — notifications not available
    }
  }

  Future<void> _storeToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'fcm_token': token}, SetOptions(merge: true));
    } catch (_) {}
  }

  void _handleMessage(RemoteMessage message) {
    // Notifications are handled by the system UI
    // This can be extended for in-app notification banners
  }
}
