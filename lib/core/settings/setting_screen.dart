import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/core/settings/app_setting_provider.dart';
import 'package:booking_app/features/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final settingsAsync = ref.watch(appSettingsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('settings'))),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Settings error: $e')),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                s.t('preferences'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              Card(
                child: SwitchListTile(
                  value: settings.notificationsEnabled,
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .setNotificationsEnabled(v),
                  title: Text(s.t('notifications')),
                  subtitle: Text(s.t('enable_booking_notifications')),
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Text(
                s.t('storage'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: cs.onSurfaceVariant,
                  ),
                  title: Text(s.t('clear_services_cache')),
                  subtitle: Text(s.t('remove_cached_services')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(s.t('clear_cache_q')),
                        content: Text(s.t('clear_cache_msg')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(s.t('cancel')),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(s.t('clear')),
                          ),
                        ],
                      ),
                    );

                    if (ok != true) return;

                    await ref.read(serviceRepoProvider).clearCache();
                    ref.invalidate(servicesProvider);
                    ref.invalidate(servicesLastUpdatedProvider);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.t('cache_cleared'))),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
