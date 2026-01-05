import 'dart:convert';
import 'package:booking_app/core/nav/nav_ky.dart';
import 'package:booking_app/core/settings/app_setting_provider.dart';
import 'package:booking_app/features/bookings/data/booking_models.dart';
import 'package:booking_app/features/bookings/presentation/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'bookings',
    'Bookings',
    description: 'Booking updates and reminders',
    importance: Importance.high,
  );
  
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (res) {
        final payload = res.payload;
        if (payload == null || payload.isEmpty) return;
        _handleTap(payload);
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<bool> areNotificationsAllowed() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await android?.areNotificationsEnabled();
    return enabled ?? true;
  }

  Future<void> showBookingCreated({
    required String bookingId,
    required String serviceTitle,
    ProviderContainer? container,
  }) async {
    if (container != null) {
      final asyncSettings = container.read(appSettingsProvider);
      final settings = asyncSettings.asData?.value;

      if (settings != null && settings.notificationsEnabled == false) {
        return;
      }
    }

    final allowed = await areNotificationsAllowed();
    if (!allowed) return;

    final payload = jsonEncode({
      'type': 'booking_details',
      'bookingId': bookingId,
    });

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      bookingId.hashCode,
      'Booking Confirmed ',
      '$serviceTitle • ID: $bookingId',
      details,
      payload: payload,
    );
  }

  void _handleTap(String payload) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    if (data['type'] != 'booking_details') return;

    final bookingId = (data['bookingId'] ?? '').toString();
    if (bookingId.isEmpty) return;

    final dummy = Booking(
      bookingId: bookingId, 
      serviceTitle: 'Booking',
      status: 'confirmed',
      date: '',
      time: '',
      totalPrice: 0,
      serviceId: '',
      userId: '',
    );

    navKey.currentState?.push(
      MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: dummy)),
    );
  }
}
