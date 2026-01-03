import 'package:booking_app/core/config.dart';
import 'package:booking_app/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'data/booking_api.dart';
import 'data/booking_models.dart';
import 'data/booking_repository.dart';

final bookingDioProvider = Provider<Dio>((ref) => createDio());

final bookingApiProvider = Provider<BookingApi>((ref) => BookingApi(ref.watch(bookingDioProvider)));

final bookingRepoProvider = Provider<BookingRepository>((ref) => BookingRepository(ref.watch(bookingApiProvider)));

///  Stateful cache: fetch once, then keep local list updated (append after create)
class BookingsController extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    final repo = ref.read(bookingRepoProvider);
    final items = await repo.fetchBookings(AppConfig.demoUserId);
    return items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookingRepoProvider);
      return repo.fetchBookings(AppConfig.demoUserId);
    });
  }
Future<void> cancelBooking(String bookingId) async {
  final previous = state.value ?? <Booking>[];
  final updated = previous.map((b) {
    if (b.bookingId == bookingId) {
      return Booking(
        bookingId: b.bookingId,
        userId: b.userId,
        serviceId: b.serviceId,
        serviceTitle: b.serviceTitle,
        date: b.date,
        time: b.time,
        status: 'cancelled',
        totalPrice: b.totalPrice,
      );
    }
    return b;
  }).toList();

  state = AsyncValue.data(updated);
}

  Future<bool> create(CreateBookingRequest req, {required String serviceTitle, required double totalPrice}) async {
    final repo = ref.read(bookingRepoProvider);

    // optimistic loading state but keep old data
    final previous = state.value ?? <Booking>[];
    state = AsyncValue.data(previous);

    try {
      final created = await repo.createBooking(req);

      //  Append local booking even if mock doesn't persist
      final newBooking = Booking(
        bookingId: created.bookingId.isNotEmpty ? created.bookingId : 'bk_${DateTime.now().millisecondsSinceEpoch}',
        userId: req.userId,
        serviceId: req.serviceId,
        serviceTitle: serviceTitle,
        date: req.date,
        time: req.time,
        status: created.status.isNotEmpty ? created.status : 'confirmed',
        totalPrice: totalPrice,
      );

      state = AsyncValue.data([newBooking, ...previous]);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final bookingsControllerProvider = AsyncNotifierProvider<BookingsController, List<Booking>>(
  BookingsController.new,
);
