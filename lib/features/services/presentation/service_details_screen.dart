import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/features/bookings/presentation/create_booking_sheet.dart';
import 'package:booking_app/features/services/data/service_models.dart';
import 'package:booking_app/features/services/presentation/service_map_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, required this.service});
  final Service service;

  String get _heroTag => 'service_image_${service.id}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = AppStrings(AppStrings.fromLocale(Localizations.localeOf(context)));

    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: _heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: service.imageUrl,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 220,
                  color: cs.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 220,
                  color: cs.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(service.rating.toStringAsFixed(1)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(service.description,
              style: Theme.of(context).textTheme.bodyLarge),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _Info(
                    icon: Icons.category_outlined,
                    title: s.t('category'),
                    value: service.category,
                  ),
                  const SizedBox(width: 12),
                  _Info(
                    icon: Icons.timer_outlined,
                    title: s.t('duration'),
                    value: '${service.durationMinutes} ${s.t('min')}',
                  ),
                  const SizedBox(width: 12),
                  _Info(
                    icon: Icons.payments_outlined,
                    title: s.t('price'),
                    value: '\$${service.price.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          _LocationSection(service: service),

          const SizedBox(height: 16),
          Text(s.t('available_times'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (service.availableTimes.isEmpty
                    ? ['09:00', '10:30', '12:00', '15:00', '18:00']
                    : service.availableTimes)
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.outlineVariant),
                      color: cs.surface,
                    ),
                    child: Text(t),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => CreateBookingSheet(service: service),
            ),
            icon: const Icon(Icons.event_available),
            label: Text(s.t('book_now')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    final loc = service.location;
    final cs = Theme.of(context).colorScheme;
    final s = AppStrings(AppStrings.fromLocale(Localizations.localeOf(context)));

    if (loc == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t('location'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                if (loc.city.trim().isNotEmpty)
                  Text(loc.city,
                      style: Theme.of(context).textTheme.bodyMedium),
                if (loc.address.trim().isNotEmpty)
                  Text(
                    loc.address,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (loc.hasCoords)
            IconButton(
              tooltip: s.t('open_map'),
              onPressed: () {
                final l = service.location!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceMapScreen(
                      title: service.title,
                      subtitle: '${l.city} • ${l.address}',
                      lat: l.lat,
                      lng: l.lng,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.map_outlined, color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
