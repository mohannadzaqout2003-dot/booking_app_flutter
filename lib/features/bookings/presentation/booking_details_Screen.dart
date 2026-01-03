import 'package:booking_app/features/bookings/data/booking_models.dart';
import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            booking.serviceTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _Row(label: 'Booking ID', value: booking.bookingId),
                  const SizedBox(height: 10),
                  _Row(label: 'Status', value: booking.status),
                  const SizedBox(height: 10),
                  _Row(label: 'Date', value: booking.date),
                  const SizedBox(height: 10),
                  _Row(label: 'Time', value: booking.time),
                  const SizedBox(height: 10),
                  _Row(
                    label: 'Price',
                    value: '\$${booking.totalPrice.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cancel will be added next ✅')),
              );
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel Booking'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
          ),
        ),
      ],
    );
  }
}
