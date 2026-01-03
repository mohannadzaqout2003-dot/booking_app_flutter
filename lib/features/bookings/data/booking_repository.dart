import 'booking_api.dart';
import 'booking_models.dart';

class BookingRepository {
  BookingRepository(this._api);
  final BookingApi _api;

  Future<List<Booking>> fetchBookings(String userId) async {
    final json = await _api.getBookings(userId: userId);
    final data = json['data'];
    if (data is! List) throw Exception('Invalid bookings data format');
    return data.map((e) => Booking.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  ///  returns created booking if server returns it
  Future<Booking> createBooking(CreateBookingRequest req) async {
    final json = await _api.createBooking(req.toJson());
    final data = json['data'];
    if (data is Map) {
      return Booking.fromJson(data.cast<String, dynamic>());
    }
    // fallback: return empty (controller will build local one)
    return Booking(
      bookingId: '',
      userId: req.userId,
      serviceId: req.serviceId,
      serviceTitle: '',
      date: req.date,
      time: req.time,
      status: '',
      totalPrice: 0,
    );
  }
}
