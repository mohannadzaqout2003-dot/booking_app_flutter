import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/core/nav/nav_ky.dart';
import 'package:booking_app/core/onboarding.dart/splash_gate.dart';
import 'package:booking_app/core/theme/app_theme.dart';
import 'package:booking_app/features/bookings/presentation/booking_dtailees_route.dart';
import 'package:booking_app/features/favorite/favorite_screen.dart';
import 'package:booking_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_controller.dart';
import 'features/bookings/presentation/bookings_screen.dart';
import 'features/services/presentation/services_screen.dart';

class BookingApp extends ConsumerWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final isArabic = locale.languageCode == 'ar';

    return themeAsync.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Theme error: $e'))),
      ),
      data: (mode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,

          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,

          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            // GlobalMaterialLocalizations.delegate,
            // GlobalWidgetsLocalizations.delegate,
            // GlobalCupertinoLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],

          builder: (context, child) {
            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },

          onGenerateRoute: (settings) {
            if (settings.name == BookingDetailsRoute.name) {
              final bookingId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => BookingDetailsRoute(bookingId: bookingId),
              );
            }
            return null;
          },

          home: const SplashGate(),
        );
      },
    );
  }
}

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;

  final _pages = const [
    ServicesScreen(),
    BookingsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    final strings = AppStrings(AppStrings.fromLocale(locale));

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            label: strings.t('discover'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            label: strings.t('bookings'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            label: strings.t('favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: strings.t('profile'),
          ),
        ],
      ),
    );
  }
}
