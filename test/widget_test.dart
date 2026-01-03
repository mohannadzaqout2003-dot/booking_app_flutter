import 'package:booking_app/features/services/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:booking_app/app.dart';

import 'package:booking_app/features/services/data/service_models.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    final fakeServices = <Service>[
      Service(
        id: 'svc_test_1',
        title: 'Test Service',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        price: 10,
        rating: 4.5,
        reviewsCount: 12,
        durationMinutes: 30,
        availableTimes: const ['10:00', '12:00'],
        location: ServiceLocation(city: "s", address: "s", lat: 2, lng: 2),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [servicesProvider.overrideWith((ref) async => fakeServices)],
        child: const BookingApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
  });
}
