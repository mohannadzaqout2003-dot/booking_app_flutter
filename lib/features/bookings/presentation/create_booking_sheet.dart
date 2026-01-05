import 'package:booking_app/core/config.dart';
import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/core/notifications/notifications_service.dart';
import 'package:booking_app/features/bookings/data/booking_models.dart';
import 'package:booking_app/features/bookings/last_create_booking_provider.dart';
import 'package:booking_app/features/bookings/provider.dart';
import 'package:booking_app/features/services/data/service_models.dart';
import 'package:booking_app/features/shared/widgets/app_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateBookingSheet extends ConsumerStatefulWidget {
  const CreateBookingSheet({super.key, required this.service});
  final Service service;

  @override
  ConsumerState<CreateBookingSheet> createState() => _CreateBookingSheetState();
}

class _CreateBookingSheetState extends ConsumerState<CreateBookingSheet> {
  final _dateCtrl = TextEditingController();
  String? _time;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = '2025-02-15';
    _time = (widget.service.availableTimes.isEmpty
        ? '11:00'
        : widget.service.availableTimes.first);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final bookingsState = ref.watch(bookingsControllerProvider);
    final isLoading = bookingsState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: isLoading
          ? SizedBox(
              height: 220,
              child: AppLoadingView(message: s.t('creating_booking')),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('create_booking'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.service.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: s.t('date'),
                    hintText: s.t('select_date'),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async => _pickDate(context, s),
                    ),
                  ),
                  onTap: () async => _pickDate(context, s),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _time,
                  items: (widget.service.availableTimes.isEmpty
                          ? ['09:00', '10:30', '12:00', '15:00', '18:00']
                          : widget.service.availableTimes)
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _time = v),
                  decoration: InputDecoration(
                    labelText: s.t('time'),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final date = _dateCtrl.text.trim();
                      final time = (_time ?? '').trim();

                      if (date.isEmpty || time.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.t('please_enter_date_time'))),
                        );
                        return;
                      }

                      final req = CreateBookingRequest(
                        userId: AppConfig.demoUserId,
                        serviceId: widget.service.id,
                        date: date,
                        time: time,
                      );

                      final ok = await ref
                          .read(bookingsControllerProvider.notifier)
                          .create(
                            req,
                            serviceTitle: widget.service.title,
                            totalPrice: widget.service.price,
                          );

                      if (!context.mounted) return;

                      if (ok) {
                        final newId = ref.read(lastCreatedBookingIdProvider);
                        if (newId != null) {
                          await NotificationService.instance.showBookingCreated(
                            bookingId: newId,
                            serviceTitle: widget.service.title,
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.t('booking_created'))),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.t('failed_create_booking'))),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(s.t('confirm_booking')),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _pickDate(BuildContext context, AppStrings s) async {
    final now = DateTime.now();

    DateTime initialDate = now;
    try {
      if (_dateCtrl.text.trim().isNotEmpty) {
        initialDate = DateTime.parse(_dateCtrl.text.trim());
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: s.t('select_booking_date'),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked == null) return;

    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');

    setState(() {
      _dateCtrl.text = '$y-$m-$d';
    });
  }
}
