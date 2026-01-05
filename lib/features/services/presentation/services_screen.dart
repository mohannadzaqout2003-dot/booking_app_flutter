import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/core/nav/app_page_route.dart';
import 'package:booking_app/features/favorite/favorites_provider.dart';
import 'package:booking_app/features/services/data/service_models.dart';
import 'package:booking_app/features/services/fillter_service_provider.dart';
import 'package:booking_app/features/services/presentation/service_details_screen.dart';
import 'package:booking_app/features/services/presentation/service_fillter.dart';
import 'package:booking_app/features/services/provider.dart';
import 'package:booking_app/features/shared/widgets/app_error_view.dart';
import 'package:booking_app/features/shared/widgets/empty_state_view.dart';
import 'package:booking_app/features/shared/widgets/skelton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(servicesFilterProvider.notifier).setQuery(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(servicesProvider);
    ref.invalidate(servicesLastUpdatedProvider);
    await Future.delayed(const Duration(milliseconds: 250));
  }

  void _clearFilters() {
    _searchCtrl.clear();
    ref.read(servicesFilterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final asyncServices = ref.watch(servicesProvider);
    final filtered = ref.watch(filteredServicesProvider);
    final cats = ref.watch(serviceCategoriesProvider);
    final filter = ref.watch(servicesFilterProvider);

    final updatedAt = ref.watch(servicesLastUpdatedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('discover')),
        actions: [
          IconButton(
            tooltip: s.t('filters'),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const _FiltersSheet(),
            ),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: asyncServices.when(
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _LastUpdatedBar(
                  updatedAt: updatedAt,
                  onClearCache: () async {
                    await ref.read(serviceRepoProvider).clearCache();
                    ref.invalidate(servicesLastUpdatedProvider);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.t('cache_cleared'))),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => const ServiceSkeletonCard(),
                ),
              ],
            ),
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _LastUpdatedBar(
                  updatedAt: updatedAt,
                  onClearCache: () async {
                    await ref.read(serviceRepoProvider).clearCache();
                    ref.invalidate(servicesLastUpdatedProvider);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.t('cache_cleared'))),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AppErrorView(
                  title: s.t('something_wrong'),
                  message: e.toString(),
                  onRetry: () => ref.invalidate(servicesProvider),
                ),
              ],
            ),
            data: (allServices) {
              if (allServices.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _LastUpdatedBar(
                      updatedAt: updatedAt,
                      onClearCache: () async {
                        await ref.read(serviceRepoProvider).clearCache();
                        ref.invalidate(servicesLastUpdatedProvider);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.t('cache_cleared'))),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    EmptyStateView(
                      icon: Icons.explore_outlined,
                      title: s.t('no_services'),
                      message: s.t('pull_to_refresh'),
                      primaryActionText: s.t('refresh'),
                      onPrimaryAction: _refresh,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _LastUpdatedBar(
                    updatedAt: updatedAt,
                    onClearCache: () async {
                      await ref.read(serviceRepoProvider).clearCache();
                      ref.invalidate(servicesLastUpdatedProvider);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.t('cache_cleared'))),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _SearchBar(
                    controller: _searchCtrl,
                    onClear: _clearFilters,
                    hint: s.t('search_hint'),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final c = cats[i];
                        final selected = c == filter.category;

                        return ChoiceChip(
                          selected: selected,
                          label: Text(c),
                          onSelected: (_) => ref
                              .read(servicesFilterProvider.notifier)
                              .setCategory(c),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        s.t('top_services'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: filtered.isEmpty
                          ? EmptyStateView(
                              key: const ValueKey('empty_filtered'),
                              icon: Icons.search_off_outlined,
                              title: s.t('no_results'),
                              message: s.t('try_change_filters'),
                              primaryActionText: s.t('clear_filters'),
                              onPrimaryAction: _clearFilters,
                            )
                          : ListView.separated(
                              key: const ValueKey('list_services'),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _ServiceCard(service: filtered[i]),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LastUpdatedBar extends ConsumerWidget {
  const _LastUpdatedBar({
    required this.updatedAt,
    required this.onClearCache,
  });

  final DateTime? updatedAt;
  final VoidCallback onClearCache;

  String _format(DateTime dt, AppStrings s) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 30) return s.t('just_now');
    if (diff.inMinutes < 1) return '${diff.inSeconds}${s.t('seconds_ago')}';
    if (diff.inHours < 1) return '${diff.inMinutes}${s.t('minutes_ago')}';
    if (diff.inDays < 1) return '${diff.inHours}${s.t('hours_ago')}';
    return '${diff.inDays}${s.t('days_ago')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final text = updatedAt == null
        ? s.t('not_cached_yet')
        : '${s.t('updated')} ${_format(updatedAt!, s)}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onClearCache,
          icon: const Icon(Icons.delete_outline),
          label: Text(s.t('clear_cache')),
        ),
      ],
    );
  }
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final bounds = ref.watch(servicesPriceBoundsProvider);
    final filter = ref.watch(servicesFilterProvider);

    final minBound = bounds.min;
    final maxBound = bounds.max;

    final currentMin = filter.minPrice.clamp(minBound, maxBound).toDouble();
    final currentMax = filter.maxPrice.clamp(minBound, maxBound).toDouble();

    RangeValues range = RangeValues(currentMin, currentMax);

    String sortLabel(ServiceSort sort) {
      switch (sort) {
        case ServiceSort.recommended:
          return 'Recommended';
        case ServiceSort.priceLowToHigh:
          return 'Price: Low → High';
        case ServiceSort.priceHighToLow:
          return 'Price: High → Low';
        case ServiceSort.ratingHighToLow:
          return 'Rating: High → Low';
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.t('filters'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              Text(s.t('sort_by'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              DropdownButtonFormField<ServiceSort>(
                initialValue: filter.sort,
                items: ServiceSort.values
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(sortLabel(v)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(servicesFilterProvider.notifier).setSort(v);
                },
                decoration: const InputDecoration(prefixIcon: Icon(Icons.sort)),
              ),

              const SizedBox(height: 16),
              Text(s.t('price_range'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),

              Text(
                '\$${range.start.toStringAsFixed(0)}  —  \$${range.end.toStringAsFixed(0)}',
              ),

              RangeSlider(
                values: range,
                min: minBound,
                max: maxBound,
                divisions: 20,
                labels: RangeLabels(
                  range.start.toStringAsFixed(0),
                  range.end.toStringAsFixed(0),
                ),
                onChanged: (v) => setLocal(() => range = v),
                onChangeEnd: (v) => ref
                    .read(servicesFilterProvider.notifier)
                    .setPriceRange(v.start, v.end),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ref.read(servicesFilterProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(s.t('reset')),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(s.t('done')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onClear,
    required this.hint,
  });

  final TextEditingController controller;
  final VoidCallback onClear;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) {
        final isEmpty = value.text.trim().isEmpty;

        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: isEmpty
                ? null
                : IconButton(onPressed: onClear, icon: const Icon(Icons.close)),
          ),
        );
      },
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  const _ServiceCard({required this.service});
  final Service service;

  String get _heroTag => 'service_image_${service.id}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final favAsync = ref.watch(favoritesProvider);
    final favs = favAsync.value ?? <String>{};
    final isFav = favs.contains(service.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute.fadeSlide(ServiceDetailsScreen(service: service)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: _heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: cs.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(cs.primary),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(service.id),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey<bool>(isFav),
                              color: isFav ? Colors.red : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (service.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        service.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
