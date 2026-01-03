import 'dart:async';
import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/features/bookings/data/booking_models.dart';
import 'package:booking_app/features/bookings/last_create_booking_provider.dart';
import 'package:booking_app/features/bookings/presentation/booking_fillter.dart';
import 'package:booking_app/features/bookings/presentation/fillter_booking_provider.dart';
import 'package:booking_app/features/bookings/provider.dart';
import 'package:booking_app/features/shared/widgets/app_error_view.dart';
import 'package:booking_app/features/shared/widgets/empty_state_view.dart';
import 'package:booking_app/features/shared/widgets/skelton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_details_screen.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final _scrollCtrl = ScrollController();
  Timer? _clearHighlightTimer;
  ProviderSubscription<String?>? _lastCreatedSub;

  @override
  void initState() {
    super.initState();

    _lastCreatedSub = ref.listenManual<String?>(
      lastCreatedBookingIdProvider,
      (prev, next) {
        if (!mounted) return;
        if (next == null) return;

        final locale = ref.read(localeControllerProvider);
        final s = AppStrings(AppStrings.fromLocale(locale));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.t('new_booking')} $next')),
        );
      },
    );
  }

  @override
  void dispose() {
    _lastCreatedSub?.close();
    _clearHighlightTimer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final asyncBookings = ref.watch(bookingsControllerProvider);
    final lastId = ref.watch(lastCreatedBookingIdProvider);

    final filtered = ref.watch(filteredBookingsProvider);
    final filter = ref.watch(bookingsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('bookings')),
        actions: [
          IconButton(
            tooltip: s.t('refresh'),
            onPressed: () => ref.read(bookingsControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: asyncBookings.when(
          loading: () => const ServiceSkeletonCard(),
          error: (e, _) => AppErrorView(
            title: s.t('something_wrong'),
            message: e.toString(),
            onRetry: () => ref.read(bookingsControllerProvider.notifier).refresh(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: s.t('no_bookings_yet'),
                message: s.t('book_first_service'),
                primaryActionText: s.t('discover_services'),
                onPrimaryAction: () => Navigator.of(context).pop(),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: Text(s.t('all')),
                        selected: filter.status == BookingStatusFilter.all,
                        onSelected: (_) => ref
                            .read(bookingsFilterProvider.notifier)
                            .setStatus(BookingStatusFilter.all),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(s.t('confirmed')),
                        selected: filter.status == BookingStatusFilter.confirmed,
                        onSelected: (_) => ref
                            .read(bookingsFilterProvider.notifier)
                            .setStatus(BookingStatusFilter.confirmed),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(s.t('completed')),
                        selected: filter.status == BookingStatusFilter.completed,
                        onSelected: (_) => ref
                            .read(bookingsFilterProvider.notifier)
                            .setStatus(BookingStatusFilter.completed),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(s.t('cancelled')),
                        selected: filter.status == BookingStatusFilter.cancelled,
                        onSelected: (_) => ref
                            .read(bookingsFilterProvider.notifier)
                            .setStatus(BookingStatusFilter.cancelled),
                      ),
                      const SizedBox(width: 12),
                      ActionChip(
                        avatar: const Icon(Icons.sort, size: 18),
                        label: Text(
                          filter.sort == BookingSort.newestFirst
                              ? s.t('newest')
                              : s.t('oldest'),
                        ),
                        onPressed: () {
                          final next = filter.sort == BookingSort.newestFirst
                              ? BookingSort.oldestFirst
                              : BookingSort.newestFirst;
                          ref.read(bookingsFilterProvider.notifier).setSort(next);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      s.t('results'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Text('${filtered.length} ${s.t('items')}'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(bookingsControllerProvider.notifier).refresh();
                    },
                    child: filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 200),
                              Center(child: Text(s.t('no_bookings_match'))),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _scrollCtrl,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final b = filtered[i];
                              final isNew = (lastId != null && b.bookingId == lastId);

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingDetailsScreen(booking: b),
                                  ),
                                ),
                                child: _BookingCard(
                                  booking: b,
                                  isHighlighted: isNew,
                                  onCancel: b.status.toLowerCase().contains('cancel')
                                      ? null
                                      : () async {
                                          final ok = await _confirmCancel(context, s);
                                          if (!ok) return;

                                          await ref
                                              .read(bookingsControllerProvider.notifier)
                                              .cancelBooking(b.bookingId);

                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(s.t('booking_cancelled'))),
                                          );
                                        },
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmCancel(BuildContext context, AppStrings s) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(s.t('cancel_booking_q')),
            content: Text(s.t('cancel_booking_msg')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.t('no')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(s.t('yes_cancel')),
              ),
            ],
          ),
        )) ??
        false;
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isHighlighted,
    required this.onCancel,
  });

  final Booking booking;
  final bool isHighlighted;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = isHighlighted ? cs.primaryContainer.withOpacity(0.35) : cs.surface;
    final border = isHighlighted ? cs.primary : cs.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: isHighlighted ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.serviceTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StatusPill(status: booking.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(booking.date),
              const SizedBox(width: 14),
              Icon(Icons.access_time, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(booking.time),
              const Spacer(),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                booking.bookingId,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              if (onCancel != null)
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = status.toLowerCase().trim();

    late final Color bg;
    late final Color fg;

    if (s.contains('confirm')) {
      bg = cs.tertiaryContainer;
      fg = cs.onTertiaryContainer;
    } else if (s.contains('cancel')) {
      bg = cs.errorContainer;
      fg = cs.onErrorContainer;
    } else if (s.contains('complete')) {
      bg = cs.secondaryContainer;
      fg = cs.onSecondaryContainer;
    } else {
      bg = cs.primaryContainer;
      fg = cs.onPrimaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? 'pending' : status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
