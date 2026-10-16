import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/shop_provider.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _gateway = 'chapa';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      _showError('Cart is empty');
      return;
    }

    setState(() => _loading = true);

    // Single-item checkout (API is per-item)
    final firstItem = cart.first;
    final repo = ref.read(shopRepositoryProvider);
    final checkout = await repo.createCheckout(
      shopId: firstItem.product.id,
      gateway: _gateway,
      phone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (checkout == null) {
      _showError('Could not start checkout. Try again.');
      return;
    }

    // Open Chapa checkout
    final uri = Uri.tryParse(checkout.checkoutUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    if (!mounted) return;

    // Show polling dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StatusDialog(orderId: checkout.orderId),
    );

    // On success, clear cart
    if (!mounted) return;
    ref.read(cartProvider.notifier).clear();
    context.go('/home');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(0, (s, i) => s + i.subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary
              Card(
                color: AppColors.lightGray,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Summary',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      ...cart.map((i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${i.quantity}× ${i.product.name}',
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${i.subtotal.toStringAsFixed(0)} ETB',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            '${total.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Delivery Information',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Payment Method',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),

              // ── Modern RadioGroup API (Flutter 3.32+) ──
              RadioGroup<String>(
                groupValue: _gateway,
                onChanged: (String? v) {
                  if (v != null) {
                    setState(() => _gateway = v);
                  }
                },
                child: const RadioListTile<String>(
                  value: 'chapa',
                  title: Text('Chapa'),
                  subtitle: Text('Pay with card or mobile money',
                      style: TextStyle(fontSize: 12)),
                  activeColor: AppColors.primaryRed,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Pay Now',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ STATUS POLLING DIALOG ============
class _StatusDialog extends ConsumerStatefulWidget {
  final String orderId;
  const _StatusDialog({required this.orderId});

  @override
  ConsumerState<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends ConsumerState<_StatusDialog> {
  String _status = 'pending';
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _pollStatus();
  }

  Future<void> _pollStatus() async {
    final repo = ref.read(shopRepositoryProvider);
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      final s = await repo.paymentStatus(widget.orderId);
      if (!mounted) return;
      if (s == null) continue;
      setState(() => _status = s.status);
      if (s.isCompleted || s.isFailed) {
        if (mounted) setState(() => _done = true);
        return;
      }
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _status == 'completed';
    final isFailed = _status == 'failed' || _status == 'cancelled';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle
                : isFailed
                    ? Icons.error
                    : Icons.hourglass_top,
            color: isSuccess
                ? AppColors.success
                : isFailed
                    ? AppColors.error
                    : AppColors.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(isSuccess
              ? 'Payment Successful'
              : isFailed
                  ? 'Payment Failed'
                  : 'Processing'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_done)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Waiting for payment...'),
              ],
            )
          else
            Text(isSuccess
                ? 'Your order has been placed successfully.'
                : 'Payment could not be completed.'),
          const SizedBox(height: 12),
          Text('Order: ${widget.orderId}',
              style: const TextStyle(fontSize: 11)),
          Text('Status: $_status',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSuccess
                    ? AppColors.success
                    : isFailed
                        ? AppColors.error
                        : AppColors.mediumGray,
              )),
        ],
      ),
      actions: [
        if (_done)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
      ],
    );
  }
}