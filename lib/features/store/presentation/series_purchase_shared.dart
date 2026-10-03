import 'package:flutter/material.dart';

const purchaseNavy = Color(0xFF062D5C);
const purchaseBlue = Color(0xFF0B5D96);
const purchasePage = Color(0xFFF8FAFD);
const purchaseLine = Color(0xFFE4E9F1);
const purchaseMuted = Color(0xFF718096);

class SeriesInfo {
  const SeriesInfo({required this.name, required this.examName});
  final String name;
  final String examName;
}

SeriesInfo seriesInfo(Map<String, dynamic> body) {
  final raw = body['series'];
  final series = raw is Map
      ? Map<String, dynamic>.from(raw)
      : const <String, dynamic>{};
  return SeriesInfo(
    name: series['name']?.toString().trim().isNotEmpty == true
        ? series['name'].toString().trim()
        : 'Test Series',
    examName: series['examName']?.toString().trim().isNotEmpty == true
        ? series['examName'].toString().trim()
        : 'Exam',
  );
}

PreferredSizeWidget purchaseAppBar(String title) => AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF10264A),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: purchaseLine),
      ),
    );

BoxDecoration purchaseCardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: purchaseLine),
    );

class PurchaseHero extends StatelessWidget {
  const PurchaseHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [purchaseNavy, purchaseBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFFD36B),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFD8E6F5),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class SecurePaymentNote extends StatelessWidget {
  const SecurePaymentNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: Color(0xFF64748B),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Payment is processed securely by Razorpay. Examtree never stores your card or UPI credentials.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class PurchaseState extends StatelessWidget {
  const PurchaseState({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon = Icons.info_outline_rounded,
    this.iconColor = const Color(0xFF718096),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, size: 38, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF10264A),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: purchaseNavy,
                  foregroundColor: Colors.white,
                ),
                child: Text(action!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReceiptRow extends StatelessWidget {
  const ReceiptRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? const Color(0xFF10264A) : purchaseMuted,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class InlinePurchaseWarning extends StatelessWidget {
  const InlinePurchaseWarning(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFC2413A),
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF9F352F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String validityLabel(int? days) {
  if (days == null) return 'Validity as published';
  if (days >= 360 && days <= 370) return '12 Months';
  if (days >= 175 && days <= 190) return '6 Months';
  if (days >= 85 && days <= 100) return '3 Months';
  if (days % 30 == 0 && days < 360) {
    return (days ~/ 30).toString() + ' Months';
  }
  return days.toString() + ' Days';
}

String formatSeriesMoney(int minor, String currency) {
  if (minor == 0) return 'Free';
  final whole = minor ~/ 100;
  final remainder = minor % 100;
  final amount = remainder == 0
      ? whole.toString()
      : whole.toString() + '.' + remainder.toString().padLeft(2, '0');
  return switch (currency.trim().toUpperCase()) {
    'INR' => '₹' + amount,
    'USD' => r'$' + amount,
    'GBP' => '£' + amount,
    'EUR' => '€' + amount,
    _ => currency.toUpperCase() + ' ' + amount,
  };
}
