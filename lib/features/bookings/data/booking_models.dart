class Booking {
  final String bookingId;
  final String userId;
  final String serviceId;
  final String serviceTitle;
  final String date;
  final String time;
  final String status;
  final double totalPrice;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.date,
    required this.time,
    required this.status,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: (json['booking_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      serviceTitle: (json['service_title'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: (json['status'] ?? 'confirmed').toString(),
      totalPrice: (json['total_price'] is num) ? (json['total_price'] as num).toDouble() : 0,
    );
  }
}

class CreateBookingRequest {
  final String userId;
  final String serviceId;
  final String date;
  final String time;

  CreateBookingRequest({
    required this.userId,
    required this.serviceId,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'service_id': serviceId,
        'date': date,
        'time': time,
      };
}
