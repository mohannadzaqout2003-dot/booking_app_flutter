import 'package:flutter/material.dart';

enum AppLang { en, ar }

class AppStrings {
  final AppLang lang;
  const AppStrings(this.lang);

  static AppLang fromLocale(Locale? locale) {
    final code = (locale?.languageCode ?? 'en').toLowerCase();
    return code == 'ar' ? AppLang.ar : AppLang.en;
  }

  static const _en = <String, String>{
    // Tabs / titles
    'discover': 'Discover',
    'bookings': 'Bookings',
    'favorites': 'Favorites',
    'profile': 'Profile',
    'settings': 'Settings',

    // Language
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',

    // Common
    'user': 'User',
    'loading': 'Loading...',
    'refresh': 'Refresh',
    'retry': 'Retry',
    'done': 'Done',
    'reset': 'Reset',
    'clear': 'Clear',
    'cancel': 'Cancel',
    'yes': 'Yes',
    'no': 'No',
    'save': 'Save',
    'results': 'Results',
    'items': 'items',

    // Services
    'filters': 'Filters',
    'search_hint': 'Search services, category...',
    'top_services': 'Top Services',
    'no_services': 'No services available',
    'pull_to_refresh': 'Please pull to refresh or try again later.',
    'no_results': 'No results',
    'try_change_filters': 'Try changing filters or clearing search.',
    'clear_filters': 'Clear filters',

    // Cache / last updated
    'not_cached_yet': 'Not cached yet',
    'updated': 'Updated',
    'clear_cache': 'Clear cache',
    'cache_cleared': 'Cache cleared ✅',
    'just_now': 'Just now',
    'seconds_ago': 's ago',
    'minutes_ago': 'm ago',
    'hours_ago': 'h ago',
    'days_ago': 'd ago',

    // Errors
    'something_wrong': 'Something went wrong',
    'could_not_load_favorites': 'Could not load favorites',

    // Favorites
    'loading_favorites': 'Loading favorites...',
    'no_favorites_yet': 'No favorites yet',
    'tap_heart_to_save': 'Tap the heart icon on any service to save it here.',
    'browse_services': 'Browse services',

    // Bookings
    'new_booking': 'New booking:',
    'no_bookings_yet': 'No bookings yet',
    'book_first_service': 'Book your first service and it will appear here.',
    'discover_services': 'Discover services',
    'no_bookings_match': 'No bookings match your filters.',
    'all': 'All',
    'confirmed': 'Confirmed',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'newest': 'Newest',
    'oldest': 'Oldest',
    'booking_cancelled': 'Booking cancelled ✅',
    'cancel_booking_q': 'Cancel booking?',
    'cancel_booking_msg': 'Are you sure you want to cancel this booking?',
    'yes_cancel': 'Yes, cancel',

    // Create booking
    'creating_booking': 'Creating booking...',
    'create_booking': 'Create Booking',
    'date': 'Date',
    'select_date': 'Select date',
    'time': 'Time',
    'confirm_booking': 'Confirm Booking',
    'please_enter_date_time': 'Please enter date & time',
    'booking_created': 'Booking created ✅',
    'failed_create_booking': 'Failed to create booking',
    'select_booking_date': 'Select booking date',

    // Settings
    'preferences': 'Preferences',
    'notifications': 'Notifications',
    'enable_booking_notifications': 'Enable booking notifications',
    'storage': 'Storage',
    'clear_services_cache': 'Clear services cache',
    'remove_cached_services': 'Remove cached services & last updated time',
    'clear_cache_q': 'Clear cache?',
    'clear_cache_msg':
        'This will remove cached services. The app will fetch again from the API.',

    // Profile
    'edit': 'Edit',
    'update_name': 'Update name',
    'update_phone': 'Update phone',
    'update_address': 'Update address',
    'add_phone': 'Add phone number',
    'add_address': 'Add address',
    'change_password': 'Change password',
    'secure_account': 'Secure your account',
    'logout': 'Logout',
    'sign_out_device': 'Sign out from this device',
    'logged_out': 'Logged out ✅',
    'dark_mode': 'Dark Mode',
    'enabled': 'Enabled',
    'disabled': 'Disabled',

    // Edit profile
    'edit_profile': 'Edit Profile',
    'name': 'Name',
    'phone': 'Phone',
    'address': 'Address',
    'first_name': 'First name',
    'last_name': 'Last name',
    'updated_ok': 'Updated ✅',
    'failed': 'Failed:',

    // Change password
    'old_password': 'Old Password',
    'new_password': 'New Password',
    'confirm_password': 'Confirm Password',
    'password_changed_ok': 'Password changed successfully!',
    'check_inputs': 'Please check your inputs!',

    // Details
    'category': 'Category',
    'duration': 'Duration',
    'price': 'Price',
    'location': 'Location',
    'open_map': 'Open map',
    'available_times': 'Available Times',
    'book_now': 'Book Now',
    'min': 'min',
  };

  static const _ar = <String, String>{
    // Tabs / titles
    'discover': 'استكشاف',
    'bookings': 'الحجوزات',
    'favorites': 'المفضلة',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',

    // Language
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',

    // Common
    'user': 'مستخدم',
    'loading': 'جاري التحميل...',
    'refresh': 'تحديث',
    'retry': 'إعادة المحاولة',
    'done': 'تم',
    'reset': 'إعادة ضبط',
    'clear': 'مسح',
    'cancel': 'إلغاء',
    'yes': 'نعم',
    'no': 'لا',
    'save': 'حفظ',
    'results': 'النتائج',
    'items': 'عنصر',

    // Services
    'filters': 'فلاتر',
    'search_hint': 'ابحث عن خدمة أو تصنيف...',
    'top_services': 'أفضل الخدمات',
    'no_services': 'لا توجد خدمات حالياً',
    'pull_to_refresh': 'اسحب للتحديث أو جرّب لاحقاً.',
    'no_results': 'لا توجد نتائج',
    'try_change_filters': 'جرّب تغيير الفلاتر أو مسح البحث.',
    'clear_filters': 'مسح الفلاتر',

    // Cache / last updated
    'not_cached_yet': 'لا يوجد كاش بعد',
    'updated': 'آخر تحديث',
    'clear_cache': 'مسح الكاش',
    'cache_cleared': 'تم مسح الكاش ✅',
    'just_now': 'الآن',
    'seconds_ago': 'ث',
    'minutes_ago': 'د',
    'hours_ago': 'س',
    'days_ago': 'ي',

    // Errors
    'something_wrong': 'حدث خطأ ما',
    'could_not_load_favorites': 'تعذر تحميل المفضلة',

    // Favorites
    'loading_favorites': 'جاري تحميل المفضلة...',
    'no_favorites_yet': 'لا توجد مفضلة بعد',
    'tap_heart_to_save': 'اضغط على القلب لأي خدمة لحفظها هنا.',
    'browse_services': 'تصفح الخدمات',

    // Bookings
    'new_booking': 'حجز جديد:',
    'no_bookings_yet': 'لا توجد حجوزات بعد',
    'book_first_service': 'احجز أول خدمة وستظهر هنا.',
    'discover_services': 'استكشاف الخدمات',
    'no_bookings_match': 'لا توجد حجوزات مطابقة للفلاتر.',
    'all': 'الكل',
    'confirmed': 'مؤكد',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
    'newest': 'الأحدث',
    'oldest': 'الأقدم',
    'booking_cancelled': 'تم إلغاء الحجز ✅',
    'cancel_booking_q': 'إلغاء الحجز؟',
    'cancel_booking_msg': 'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟',
    'yes_cancel': 'نعم، إلغاء',

    // Create booking
    'creating_booking': 'جاري إنشاء الحجز...',
    'create_booking': 'إنشاء حجز',
    'date': 'التاريخ',
    'select_date': 'اختر التاريخ',
    'time': 'الوقت',
    'confirm_booking': 'تأكيد الحجز',
    'please_enter_date_time': 'يرجى إدخال التاريخ والوقت',
    'booking_created': 'تم إنشاء الحجز ✅',
    'failed_create_booking': 'فشل إنشاء الحجز',
    'select_booking_date': 'اختر تاريخ الحجز',

    // Settings
    'preferences': 'التفضيلات',
    'notifications': 'الإشعارات',
    'enable_booking_notifications': 'تفعيل إشعارات الحجوزات',
    'storage': 'التخزين',
    'clear_services_cache': 'مسح كاش الخدمات',
    'remove_cached_services': 'حذف الخدمات المخزنة ووقت آخر تحديث',
    'clear_cache_q': 'مسح الكاش؟',
    'clear_cache_msg':
        'سيتم حذف الخدمات المخزنة وسيتم جلبها مجددًا من الـ API.',

    // Profile
    'edit': 'تعديل',
    'update_name': 'تعديل الاسم',
    'update_phone': 'تعديل الهاتف',
    'update_address': 'تعديل العنوان',
    'add_phone': 'أضف رقم الهاتف',
    'add_address': 'أضف العنوان',
    'change_password': 'تغيير كلمة المرور',
    'secure_account': 'حماية حسابك',
    'logout': 'تسجيل الخروج',
    'sign_out_device': 'تسجيل الخروج من هذا الجهاز',
    'logged_out': 'تم تسجيل الخروج ✅',
    'dark_mode': 'الوضع الليلي',
    'enabled': 'مفعل',
    'disabled': 'غير مفعل',

    // Edit profile
    'edit_profile': 'تعديل الملف الشخصي',
    'name': 'الاسم',
    'phone': 'الهاتف',
    'address': 'العنوان',
    'first_name': 'الاسم الأول',
    'last_name': 'اسم العائلة',
    'updated_ok': 'تم التحديث ✅',
    'failed': 'فشل:',

    // Change password
    'old_password': 'كلمة المرور القديمة',
    'new_password': 'كلمة المرور الجديدة',
    'confirm_password': 'تأكيد كلمة المرور',
    'password_changed_ok': 'تم تغيير كلمة المرور بنجاح!',
    'check_inputs': 'يرجى التأكد من المدخلات!',

    // Details
    'category': 'التصنيف',
    'duration': 'المدة',
    'price': 'السعر',
    'location': 'الموقع',
    'open_map': 'فتح الخريطة',
    'available_times': 'الأوقات المتاحة',
    'book_now': 'احجز الآن',
    'min': 'دقيقة',
  };

  String t(String key) {
    final map = lang == AppLang.ar ? _ar : _en;
    return map[key] ?? _en[key] ?? key;
  }
}
