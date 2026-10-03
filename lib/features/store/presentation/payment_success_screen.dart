import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'series_purchase_shared.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.seriesId,
    required this.orderId,
    required this.orderNumber,
  });

  final String seriesId;
  final String orderId;
  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purchasePage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 46,
                  color: Color(0xFF10996F),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF10264A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your test series access is active.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: purchaseMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: purchaseCardDecoration(),
                child: Column(
                  children: [
                    ReceiptRow(
                      label: 'Order',
                      value: orderNumber.isEmpty ? orderId : orderNumber,
                    ),
                    const Divider(height: 22, color: purchaseLine),
                    const ReceiptRow(
                      label: 'Status',
                      value: 'Paid • Access activated',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Here you go, Officer!',
                style: TextStyle(
                  color: purchaseNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go(
                  '/test-series?id=' + Uri.encodeQueryComponent(seriesId),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: purchaseNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text(
                  'Open Test Series',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
