class Service {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final double rating;
  final int reviewsCount;
  final int durationMinutes;
  final List<String> availableTimes;
  final ServiceLocation? location;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.durationMinutes,
    required this.availableTimes,
    required this.location,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0,
      reviewsCount: (json['reviews_count'] is num)
          ? (json['reviews_count'] as num).toInt()
          : 0,
      durationMinutes: (json['duration_minutes'] is num)
          ? (json['duration_minutes'] as num).toInt()
          : 0,
      availableTimes: (json['available_times'] is List)
          ? (json['available_times'] as List).map((e) => e.toString()).toList()
          : const [],
      location: (json['location'] is Map)
          ? ServiceLocation.fromJson(
              (json['location'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'price': price,
      'rating': rating,
      'reviews_count': reviewsCount,
      'duration_minutes': durationMinutes,
      'available_times': availableTimes,
      'location': location?.toJson(),
    };
  }
}

class ServiceLocation {
  final String city;
  final String address;
  final double lat;
  final double lng;

  const ServiceLocation({
    required this.city,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      city: (json['city'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }

  bool get hasCoords => lat != 0.0 || lng != 0.0;
}
