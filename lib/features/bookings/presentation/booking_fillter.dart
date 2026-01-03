import 'package:flutter_riverpod/legacy.dart';

enum BookingStatusFilter { all, confirmed, completed, cancelled }

enum BookingSort { newestFirst, oldestFirst }

class BookingsFilterState {
  final BookingStatusFilter status;
  final BookingSort sort;

  const BookingsFilterState({
    this.status = BookingStatusFilter.all,
    this.sort = BookingSort.newestFirst,
  });

  BookingsFilterState copyWith({
    BookingStatusFilter? status,
    BookingSort? sort,
  }) {
    return BookingsFilterState(
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }
}

class BookingsFilterController extends StateNotifier<BookingsFilterState> {
  BookingsFilterController() : super(const BookingsFilterState());

  void setStatus(BookingStatusFilter s) => state = state.copyWith(status: s);
  void setSort(BookingSort s) => state = state.copyWith(sort: s);

  void reset() => state = const BookingsFilterState();
}

final bookingsFilterProvider =
    StateNotifierProvider<BookingsFilterController, BookingsFilterState>(
  (ref) => BookingsFilterController(),
);
