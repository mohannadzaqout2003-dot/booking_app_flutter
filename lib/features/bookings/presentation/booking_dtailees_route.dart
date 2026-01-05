import 'package:booking_app/features/bookings/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booking_details_screen.dart';

class BookingDetailsRoute extends ConsumerWidget {
  const BookingDetailsRoute({super.key, required this.bookingId});
  static const name = '/bookingDetails';

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingsControllerProvider);

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: Center(child: Text('Failed to load bookings: $e')),
      ),
      data: (list) {
        final booking = list.where((b) => b.bookingId == bookingId).toList();
        if (booking.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Booking not found')),
          );
        }
        return BookingDetailsScreen(booking: booking.first);
      },
    );
  }
}
