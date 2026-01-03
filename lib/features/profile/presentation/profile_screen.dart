import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/core/theme/theme_controller.dart';
import 'package:booking_app/features/profile/presentation/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final modeAsync = ref.watch(themeControllerProvider);
    final mode = modeAsync.value ?? ThemeMode.system;
    final isDark = mode == ThemeMode.dark;

    final locale = ref.watch(localeControllerProvider);
    final strings = AppStrings(AppStrings.fromLocale(locale));

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.t('profile'))),
      body: profileAsync.when(
        loading: () => Center(child: Text(strings.t('loading'))),
        error: (e, _) =>
            Center(child: Text('${strings.t('something_wrong')}: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(strings.t('something_wrong')));
          }

          final isArabic = locale.languageCode == 'ar';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundImage: (profile.photoUrl.isNotEmpty)
                        ? NetworkImage(profile.photoUrl)
                        : null,
                    child: profile.photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 34)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName.isEmpty
                              ? strings.t('user')
                              : profile.fullName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: strings.t('edit'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _SectionCard(
                children: [
                  _Tile(
                    icon: Icons.person_outline,
                    title: strings.t('update_name'),
                    subtitle: profile.fullName,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(
                          initialTab: EditProfileTab.name,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _Tile(
                    icon: Icons.phone_outlined,
                    title: strings.t('update_phone'),
                    subtitle: profile.phone.isEmpty
                        ? strings.t('add_phone')
                        : profile.phone,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(
                          initialTab: EditProfileTab.phone,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _Tile(
                    icon: Icons.location_on_outlined,
                    title: strings.t('update_address'),
                    subtitle: profile.address.isEmpty
                        ? strings.t('add_address')
                        : profile.address,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(
                          initialTab: EditProfileTab.address,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _SectionCard(
                children: [
                  _Tile(
                    icon: Icons.lock_outline,
                    title: strings.t('change_password'),
                    subtitle: strings.t('secure_account'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _Tile(
                    icon: Icons.logout,
                    title: strings.t('logout'),
                    subtitle: strings.t('sign_out_device'),
                    titleColor: cs.error,
                    iconColor: cs.error,
                    onTap: () async {
                      await ref.read(firebaseAuthProvider).signOut();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.t('logged_out'))),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ✅ Dark mode
              ListTile(
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: Text(strings.t('dark_mode')),
                subtitle: Text(
                  isDark ? strings.t('enabled') : strings.t('disabled'),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).toggleDark(v),
                ),
              ),

              // ✅ Language switch
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(strings.t('language')),
                  subtitle: Text(
                    isArabic ? strings.t('arabic') : strings.t('english'),
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  trailing: Switch(
                    value: isArabic,
                    onChanged: (v) async {
                      await ref
                          .read(localeControllerProvider.notifier)
                          .setLang(v ? 'ar' : 'en');
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
