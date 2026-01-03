import 'package:booking_app/features/bookings/data/booking_models.dart';
import 'package:booking_app/features/bookings/presentation/booking_fillter.dart';
import 'package:booking_app/features/bookings/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _parseDateTime(String date, String time) {
  // date: YYYY-MM-DD, time: HH:mm
  try {
    final dt = DateTime.parse('$date $time:00');
    return dt;
  } catch (_) {
    return DateTime(2000);
  }
}

final filteredBookingsProvider = Provider<List<Booking>>((ref) {
  final filter = ref.watch(bookingsFilterProvider);
  final async = ref.watch(bookingsControllerProvider);

  final items = async.value ?? const <Booking>[];

  // 1) status filter
  final filtered = items.where((b) {
    final s = (b.status).toLowerCase().trim();

    switch (filter.status) {
      case BookingStatusFilter.all:
        return true;
      case BookingStatusFilter.confirmed:
        return s.contains('confirm');
      case BookingStatusFilter.completed:
        return s.contains('complete');
      case BookingStatusFilter.cancelled:
        return s.contains('cancel');
    }
  }).toList();

  // 2) sort
  filtered.sort((a, b) {
    final adt = _parseDateTime(a.date, a.time);
    final bdt = _parseDateTime(b.date, b.time);
    final cmp = adt.compareTo(bdt);
    return (filter.sort == BookingSort.newestFirst) ? -cmp : cmp;
  });

  return filtered;
});
