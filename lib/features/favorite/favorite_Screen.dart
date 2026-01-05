import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/features/favorite/favorites_provider.dart';
import 'package:booking_app/features/services/presentation/service_details_screen.dart';
import 'package:booking_app/features/services/provider.dart';
import 'package:booking_app/features/shared/widgets/app_error_view.dart';
import 'package:booking_app/features/shared/widgets/app_loading_view.dart';
import 'package:booking_app/features/shared/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final servicesAsync = ref.watch(servicesProvider);
    final favs = ref.watch(favoritesProvider).value ?? <String>{};

    return Scaffold(
      appBar: AppBar(title: Text(s.t('favorites'))),
      body: servicesAsync.when(
        loading: () => AppLoadingView(message: s.t('loading_favorites')),
        error: (e, _) => AppErrorView(
          title: s.t('could_not_load_favorites'),
          message: e.toString(),
          onRetry: () => ref.invalidate(servicesProvider),
        ),
        data: (services) {
          final favServices = services.where((x) => favs.contains(x.id)).toList();

          if (favServices.isEmpty) {
            return EmptyStateView(
              icon: Icons.favorite_border,
              title: s.t('no_favorites_yet'),
              message: s.t('tap_heart_to_save'),
              primaryActionText: s.t('browse_services'),
              onPrimaryAction: () => Navigator.of(context).pop(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favServices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = favServices[i];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailsScreen(service: item),
                  ),
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                // ignore: deprecated_member_use
                                .withOpacity(0.35),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: const Icon(Icons.favorite, color: Colors.red),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
