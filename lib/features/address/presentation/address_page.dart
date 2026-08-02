import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/widgets/rimi_mark.dart';

/// Address list provider.
final addressListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.listAddresses();
});

class AddressesPage extends ConsumerStatefulWidget {
  const AddressesPage({super.key});

  @override
  ConsumerState<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends ConsumerState<AddressesPage> {
  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RimiColors.neutral),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Daftar Alamat', style: TextStyle(color: RimiColors.neutral, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: RimiColors.secondary,
        onRefresh: () async => ref.invalidate(addressListProvider),
        child: addressesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorOrEmpty(
            icon: Icons.error_outline,
            title: 'Gagal memuat',
            subtitle: apiErrorMessage(e),
            onRetry: () => ref.invalidate(addressListProvider),
          ),
          data: (addresses) {
            if (addresses.isEmpty) {
              return const _ErrorOrEmpty(
                icon: Icons.location_on_outlined,
                title: 'Belum ada alamat',
                subtitle: 'Tambahkan alamat pengirimanmu',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final addr = addresses[i];
                return _AddressCard(
                  data: addr,
                  onEdit: () async {
                    final result = await context.push<bool>('/addresses/edit/${addr['id']}');
                    if (result == true) ref.invalidate(addressListProvider);
                  },
                  onDelete: () => _confirmDelete(addr['id'].toString()),
                  onSetDefault: () => _setDefault(addr['id'].toString()),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: RimiColors.border))),
        child: SafeArea(
          top: false,
          child: FilledButton.icon(
            onPressed: () async {
              final result = await context.push<bool>('/addresses/new');
              if (result == true) ref.invalidate(addressListProvider);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Alamat', style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: RimiColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: const Text('Alamat yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: TextStyle(color: RimiColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiClientProvider).deleteAddress(id);
      ref.invalidate(addressListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat dihapus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${apiErrorMessage(e)}')));
      }
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await ref.read(apiClientProvider).updateAddress(id, isDefault: true);
      ref.invalidate(addressListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${apiErrorMessage(e)}')));
      }
    }
  }
}

// ─── Address Card ───
class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.data, required this.onEdit, required this.onDelete, required this.onSetDefault});
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final name = data['recipient_name']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? '';
    final detail = data['detail']?.toString() ?? '';
    final province = data['province']?.toString() ?? '';
    final city = data['city']?.toString() ?? '';
    final district = data['district']?.toString() ?? '';
    final village = data['village']?.toString() ?? '';
    final postalCode = data['postal_code']?.toString() ?? '';
    final label = data['label']?.toString() ?? '';
    final isDefault = data['is_default'] == true;

    final fullAddress = [
      detail,
      village.isNotEmpty ? village : null,
      district.isNotEmpty ? district : null,
      city.isNotEmpty ? city : null,
      province.isNotEmpty ? province : null,
      postalCode.isNotEmpty ? postalCode : null,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RimiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(name, style: RimiTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    if (label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: RimiColors.cloud, borderRadius: BorderRadius.circular(6)),
                        child: Text(label, style: RimiTypography.labelSmall.copyWith(fontSize: 10, color: RimiColors.primary, fontWeight: FontWeight.w700)),
                      ),
                    if (isDefault) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: RimiColors.coralSoft, borderRadius: BorderRadius.circular(6)),
                        child: Text('Utama', style: RimiTypography.labelSmall.copyWith(fontSize: 10, color: RimiColors.secondary, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                  if (v == 'default') onSetDefault();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Jadikan Utama')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: RimiColors.error))),
                ],
                icon: const Icon(Icons.more_vert_rounded, color: RimiColors.neutralMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(phone, style: RimiTypography.bodySmall),
          const SizedBox(height: 6),
          Text(fullAddress, style: RimiTypography.bodyMedium.copyWith(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

// ─── Add/Edit Address Form Page ───
class AddressFormPage extends ConsumerStatefulWidget {
  const AddressFormPage({super.key, this.addressId, this.existing});
  final String? addressId;
  final Map<String, dynamic>? existing;

  @override
  ConsumerState<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends ConsumerState<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _label;
  late final TextEditingController _recipient;
  late final TextEditingController _phone;
  late final TextEditingController _detail;
  late final TextEditingController _province;
  late final TextEditingController _city;
  late final TextEditingController _district;
  late final TextEditingController _village;
  late final TextEditingController _postalCode;
  bool _isDefault = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _label = TextEditingController(text: e?['label']?.toString() ?? '');
    _recipient = TextEditingController(text: e?['recipient_name']?.toString() ?? '');
    _phone = TextEditingController(text: e?['phone']?.toString() ?? '');
    _detail = TextEditingController(text: e?['detail']?.toString() ?? '');
    _province = TextEditingController(text: e?['province']?.toString() ?? '');
    _city = TextEditingController(text: e?['city']?.toString() ?? '');
    _district = TextEditingController(text: e?['district']?.toString() ?? '');
    _village = TextEditingController(text: e?['village']?.toString() ?? '');
    _postalCode = TextEditingController(text: e?['postal_code']?.toString() ?? '');
    _isDefault = e?['is_default'] == true;
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _detail.dispose();
    _province.dispose();
    _city.dispose();
    _district.dispose();
    _village.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      if (widget.addressId != null) {
        await api.updateAddress(widget.addressId!, 
          label: _label.text.trim(),
          recipientName: _recipient.text.trim(),
          phone: _phone.text.trim(),
          detail: _detail.text.trim(),
          province: _province.text.trim(),
          city: _city.text.trim(),
          district: _district.text.trim(),
          village: _village.text.trim(),
          postalCode: _postalCode.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        await api.createAddress(
          label: _label.text.trim(),
          recipientName: _recipient.text.trim(),
          phone: _phone.text.trim(),
          detail: _detail.text.trim(),
          province: _province.text.trim(),
          city: _city.text.trim(),
          district: _district.text.trim(),
          village: _village.text.trim(),
          postalCode: _postalCode.text.trim(),
          isDefault: _isDefault,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.addressId != null ? 'Alamat diperbarui' : 'Alamat ditambahkan')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${apiErrorMessage(e)}')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.addressId != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RimiColors.neutral),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(isEdit ? 'Edit Alamat' : 'Tambah Alamat', style: const TextStyle(color: RimiColors.neutral, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            _FormField(label: 'Label (opsional)', controller: _label, hint: 'Rumah, Kantor, dst.'),
            const SizedBox(height: 12),
            _FormField(label: 'Nama Penerima', controller: _recipient, hint: 'Nama lengkap', required: true),
            const SizedBox(height: 12),
            _FormField(label: 'No. Telepon', controller: _phone, hint: '08xxxxxxxxxx', required: true, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _FormField(label: 'Alamat Lengkap', controller: _detail, hint: 'Jl. ... No. ... RT/RW', required: true, maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _FormField(label: 'Provinsi', controller: _province, hint: 'DKI Jakarta')),
                const SizedBox(width: 10),
                Expanded(child: _FormField(label: 'Kota', controller: _city, hint: 'Jakarta Selatan')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _FormField(label: 'Kecamatan', controller: _district, hint: 'Kebayoran Baru')),
                const SizedBox(width: 10),
                Expanded(child: _FormField(label: 'Kelurahan', controller: _village, hint: 'Senayan')),
              ],
            ),
            const SizedBox(height: 12),
            _FormField(label: 'Kode Pos', controller: _postalCode, hint: '12190', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v ?? false),
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('Jadikan alamat utama', style: RimiTypography.bodyMedium.copyWith(fontSize: 14)),
              activeColor: RimiColors.secondary,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: RimiColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Alamat', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label + (required ? ' *' : ''),
            style: RimiTypography.labelMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: RimiTypography.bodySmall.copyWith(color: RimiColors.neutralMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: RimiColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: RimiColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: RimiColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorOrEmpty extends StatelessWidget {
  const _ErrorOrEmpty({required this.icon, required this.title, required this.subtitle, this.onRetry});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 72, color: RimiColors.neutralMuted),
                const SizedBox(height: 16),
                Text(title, style: RimiTypography.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: RimiTypography.bodyMedium, textAlign: TextAlign.center),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
