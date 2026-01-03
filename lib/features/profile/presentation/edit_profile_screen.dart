import 'package:booking_app/core/lacalization/app_string.dart';
import 'package:booking_app/core/lacalization/local_controller.dart';
import 'package:booking_app/features/profile/presentation/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EditProfileTab { name, phone, address }

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.initialTab = EditProfileTab.name});

  final EditProfileTab initialTab;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late EditProfileTab _tab;

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AppStrings s) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final fs = ref.read(firestoreProvider);
      final refDoc = fs.collection('users').doc(user.uid);

      final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

      if (_tab == EditProfileTab.name) {
        data['firstName'] = _firstCtrl.text.trim();
        data['lastName'] = _lastCtrl.text.trim();

        final displayName = '${_firstCtrl.text.trim()} ${_lastCtrl.text.trim()}'
            .trim();
        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
      } else if (_tab == EditProfileTab.phone) {
        data['phone'] = _phoneCtrl.text.trim();
      } else {
        data['address'] = _addressCtrl.text.trim();
      }

      await refDoc.set(data, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.t('updated_ok'))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${s.t('failed')} $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    final s = AppStrings(AppStrings.fromLocale(locale));

    final profile = ref.watch(userProfileProvider).value;

    if (profile != null) {
      if (_firstCtrl.text.isEmpty && _lastCtrl.text.isEmpty) {
        _firstCtrl.text = profile.firstName;
        _lastCtrl.text = profile.lastName;
      }
      if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = profile.phone;
      if (_addressCtrl.text.isEmpty) _addressCtrl.text = profile.address;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('edit_profile')),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(s),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.t('save')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<EditProfileTab>(
            segments: [
              ButtonSegment(
                value: EditProfileTab.name,
                label: Text(s.t('name')),
                icon: const Icon(Icons.person_outline),
              ),
              ButtonSegment(
                value: EditProfileTab.phone,
                label: Text(s.t('phone')),
                icon: const Icon(Icons.phone_outlined),
              ),
              ButtonSegment(
                value: EditProfileTab.address,
                label: Text(s.t('address')),
                icon: const Icon(Icons.location_on_outlined),
              ),
            ],
            selected: {_tab},
            onSelectionChanged: (set) => setState(() => _tab = set.first),
          ),
          const SizedBox(height: 16),

          if (_tab == EditProfileTab.name) ...[
            TextField(
              controller: _firstCtrl,
              decoration: InputDecoration(labelText: s.t('first_name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastCtrl,
              decoration: InputDecoration(labelText: s.t('last_name')),
            ),
          ] else if (_tab == EditProfileTab.phone) ...[
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: s.t('phone')),
            ),
          ] else ...[
            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(labelText: s.t('address')),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}
